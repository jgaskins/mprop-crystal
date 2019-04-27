require "granite/adapter/pg"

Granite::Adapters << Granite::Adapter::Pg.new({
  name: "postgres",
  url: ENV["DATABASE_URL"],
})

class Property < Granite::Base
  adapter postgres

  field tax_key : Int64
  field address : String
  field bedrooms : Int32
  field bathrooms : Int32
  field area : Int32
  field assessment : Int32
  field parking_type : String

  # I couldn't figure out how to get Granite to work with Postgres fulltext
  # search so I just wrote the SQL by hand.
  def self.search(
    bedrooms : Range(Int64, Int64),
    bathrooms : Range(Int64, Int64),
    area : Range(Int64, Int64),
    parking_type : String,
    address : String,
  )
    all <<-SQL,
      WHERE property.bedrooms >= $1
      AND   property.bedrooms <= $2
      AND   property.bathrooms >= $3
      AND   property.bathrooms <= $4
      AND   property.area >= $5
      AND   property.area <= $6
      AND (
        CASE $7
        WHEN '' THEN TRUE
        ELSE property.parking_type = $7
        END
      )
      AND (
        CASE $8
        WHEN '' THEN TRUE
        ELSE to_tsvector('english', property.address) @@ to_tsquery('english', $8)
        END
      )

      ORDER BY assessment DESC
      LIMIT 25
    SQL
      [
        bedrooms.begin, # $1
        bedrooms.end, # $2
        bathrooms.begin, # $3
        bathrooms.end, # $4
        area.begin, # $5
        area.end, # $6
        parking_type, # $7
        address, # $8
      ]
  end
end
