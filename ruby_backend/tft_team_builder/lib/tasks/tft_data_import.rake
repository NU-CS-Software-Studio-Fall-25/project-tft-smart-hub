# frozen_string_literal: true

require Rails.root.join("lib/services/importers/tft_data_importer")

namespace :tft do
  desc "Import TFT data files into the local database (SET env var optional)"
  task import: :environment do
    set_identifier = ENV["SET"].presence || TeamComp::DEFAULT_SET_IDENTIFIER
    importer = Importers::TftDataImporter.new(set_identifier:)
    importer.call

    puts "Imported #{Champion.where(set_identifier: set_identifier).count} champions, "\
         "#{Trait.where(set_identifier: set_identifier).count} traits, "\
         "#{TeamComp.where(set_identifier: set_identifier).count} team comps"
  end
end
