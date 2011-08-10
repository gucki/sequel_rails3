namespace :db do
  task :load_config => :environment do
    Sequel.extension :migration
    Sequel.extension :schema_dumper
  end

  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n.'
  task :rollback => :load_config do
    Rake::Task["db:migrate:down"].invoke
  end

  desc 'Drops and recreates the database from db/schema.rb for the current environment.'
  task :reset => ['db:schema:drop', 'db:schema:load']

  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do
    seed_file = File.join(Rails.root, 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
    puts "Database seeded."
  end

  desc 'Create the database, load the schema, and initialize with the seed data.'
  task :setup => ['db:schema:load', 'db:seed']

  namespace :schema do
    desc "Drops the schema from db/schema.rb."
    task :drop => :load_config do
      SequelRails3::Railtie.schema(:down)
      puts "Database schema dropped."
    end

    desc "Loads the schema from db/schema.rb."
    task :load => :load_config do
      SequelRails3::Railtie.schema(:up)
      puts "Database schema loaded version #{SequelRails3::Railtie.migrator.current}."
    end

    desc "Dumps the schema to db/schema.db."
    task :dump => :load_config do
      SequelRails3::Railtie.schema(:dump)
      puts "Database schema version #{SequelRails3::Railtie.migrator.current} dumped."
    end

    desc "Shows the current schema version."
    task :version => :load_config do
      puts "Database schema version: #{SequelRails3::Railtie.migrator.current}."
    end
  end

  desc "Runs all pending migrations and updates the schema afterwards. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :load_config do
    SequelRails3::Railtie.migrate_to(nil)
    Rake::Task["db:schema:dump"].invoke
    Rake::Task["db:schema:version"].invoke
  end

  namespace :migrate do
    desc 'Rollbacks the database one migration and re-migrate up. Specify the number of steps with STEP=x (default 1). Target specific version with VERSION=x.'
    task :redo => :load_config do
      Rake::Task["db:rollback"].invoke
      Rake::Task["db:migrate"].invoke
    end

    desc 'Runs the "up" for a given migration VERSION=x or STEP=x (default 1).'
    task :up => :load_config do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      version ||= SequelRails3::Railtie.migrator.current + step
      puts "Migrating up to version #{version}..."
      SequelRails3::Railtie.migrate_to(version)
      Rake::Task["db:schema:dump"].invoke
    end

    desc 'Runs the "down" for a given migration VERSION=x or STEP=x (default 1).'
    task :down => :load_config do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      version ||= SequelRails3::Railtie.migrator.current - step
      puts "Migrating down to version #{version}..."
      SequelRails3::Railtie.migrate_to(version)
      Rake::Task["db:schema:dump"].invoke
    end
  end
end

