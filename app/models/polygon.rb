class Polygon < ApplicationRecord
  # Validações
  validates :name, presence: true
  validates :coordinates, presence: true
  validates :description, presence: true

  # Método para converter coordenadas JSON em array
  def coordinates_array
    JSON.parse(coordinates)
  end

  # Método para calcular centro do polígono (opcional)
  def center_point
    coords = coordinates_array
    return nil if coords.empty?

    lat_sum = coords.sum { |coord| coord['lat'] }
    lng_sum = coords.sum { |coord| coord['lng'] }
    count = coords.length

    {
      lat: lat_sum / count,
      lng: lng_sum / count
    }
  end
end