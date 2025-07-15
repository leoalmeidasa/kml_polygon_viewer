class MapsController < ApplicationController
  def index
    @polygons = Polygon.all
  end

  def upload_kml
    if params[:kml_file].present?
      begin
        kml_content = params[:kml_file].read
        polygons = parse_kml(kml_content)

        # Criar novos polígonos
        created_count = 0
        polygons.each do |polygon_data|
          polygon = Polygon.create!(
            name: polygon_data[:name],
            description: polygon_data[:description],
            coordinates: polygon_data[:coordinates].to_json
          )
          created_count += 1 if polygon.persisted?
        end

        redirect_to root_path, notice: "KML processado com sucesso! #{created_count} polígono(s) carregado(s)."
      rescue => e
        redirect_to root_path, alert: "Erro ao processar KML: #{e.message}"
      end
    else
      redirect_to root_path, alert: "Por favor, selecione um arquivo KML."
    end
  end

  private

  def parse_kml(kml_content)
    require 'nokogiri'

    doc = Nokogiri::XML(kml_content)
    doc.remove_namespaces!

    polygons = []

    # Procurar por Placemarks que contenham Polygons
    doc.xpath('//Placemark').each do |placemark|
      polygon_elem = placemark.at_xpath('.//Polygon')
      next unless polygon_elem

      name = extract_name(placemark)
      description = extract_description(placemark)
      coordinates = extract_coordinates(polygon_elem)

      if coordinates.any?
        polygons << {
          name: name,
          description: description,
          coordinates: coordinates
        }
      end
    end

    polygons
  end

  def extract_name(placemark)
    name_elem = placemark.at_xpath('.//name')
    name_elem&.text&.strip || 'Polígono sem nome'
  end

  def extract_description(placemark)
    desc_elem = placemark.at_xpath('.//description')
    desc_elem&.text&.strip || 'Sem descrição'
  end

  def extract_coordinates(polygon_elem)
    coordinates_elem = polygon_elem.at_xpath('.//coordinates')
    return [] unless coordinates_elem

    coordinates_text = coordinates_elem.text.strip
    parse_coordinates_text(coordinates_text)
  end

  def parse_coordinates_text(coordinates_text)
    coordinates = []

    # Dividir por espaços ou quebras de linha
    coordinates_text.split(/\s+/).each do |coord_str|
      next if coord_str.blank?

      # Formato: longitude,latitude,altitude (altitude é opcional)
      parts = coord_str.split(',')
      if parts.length >= 2
        lng = parts[0].to_f
        lat = parts[1].to_f

        # Validar coordenadas
        if valid_coordinate?(lat, lng)
          coordinates << { lat: lat, lng: lng }
        end
      end
    end

    coordinates
  end

  def valid_coordinate?(lat, lng)
    lat.between?(-90, 90) && lng.between?(-180, 180)
  end
end