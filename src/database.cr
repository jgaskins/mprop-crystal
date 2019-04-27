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
end
