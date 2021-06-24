namespace :remove do
  task :duplicates_account_information => :environment do
    query = <<-SQL
        select hex(id) as id, hex(account_id) as account_id, `key`, count(*)
        from account_informations
        group by account_id, `key`
        having count(*) > 1;
    SQL

    duplicates = ActiveRecord::Base.connection.exec_query(query).to_hash

    file = File.new("#{Rails.root}/log/remove_duplicates_account_information.log", 'w+')

    duplicates.each do |duplicate|
      file.write("id: #{duplicate['id']}, account_id: #{duplicate['account_id']}, key: #{duplicate['key']}, remove_date: #{Time.now}\n")
      AccountInformation.find(duplicate['id']).delete
    end
    file.close
  end
end
