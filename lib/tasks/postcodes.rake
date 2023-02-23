namespace :postcodes do
  desc "imort postcodes and wards to create geozones"

logger = Logger.new('logfile.log')
logger.info "Something happened"

  task import_csv: :environment do
    CSV.foreach(Rails.root.join("db", "wards.csv"), headers: true) do |row|
     p row
        ward = "init"
	ward = row["ward"]

       logger.info "Row being imported is #{row}"
       logger.info "ward should be #{ward}"
       if ward.present?
          geozone = Geozone.find_or_create_by!(name: ward)
          code = row["postcode"]

          if Postcode.exists?(postcode: code)
          logger.info "ward is present #{code} postcode exists as #{code}"
          Postcode.update(postcode: code, ward:ward, geozone_id: geozone.id) if code.present?
          end
          Postcode.create!(postcode: code, ward:ward, geozone_id: geozone.id) unless  code.present?
    end
    end

  end

end
