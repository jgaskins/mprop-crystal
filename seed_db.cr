require "csv"
require "./src/database"

Property.migrator.drop_and_create

CSV.new(ARGF, headers: true) do |row|
  Property.create!(
    tax_key: row["TAXKEY"].to_i64,
    address: "#{row["HOUSE_NR_LO"]} #{row["SDIR"]} #{row["STREET"]} #{row["STTYPE"]}",
    bedrooms: row["BEDROOMS"].to_i32,
    bathrooms: row["BATHS"].to_i32,
    area: row["BLDG_AREA"].to_i32,
    assessment: row["C_A_TOTAL"].to_i32,
    parking_type: row["PARKING_TYPE"],
  )
end
