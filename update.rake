namespace :update do
  task :update_cpf_cnpj => :environment do
    query_value = <<-SQL
      select inf.value, hex(inf.account_id) as account_id, hex(acc.id) as id from accounts as acc
      INNER JOIN account_informations AS inf
      ON inf.account_id = acc.id
      WHERE inf.key = 'cpf' or inf.key = 'cnpj'
      -- WHERE (inf.key = 'cpf' or inf.key = 'cnpj') and inf.created_at between
    SQL
    informations = ActiveRecord::Base.connection.exec_query(query_value).to_hash

    informations.each do |result|
      puts "listando  #{result['value']}"

      unless CpfCnpj.valid_cnpj?(result['value']) || CpfCnpj.valid_cpf?(result['value'])
        puts "documeto não válido #{result['value']}"
      end

      #inseri na raw_
      query_update = Account.find(result['account_id'])
          .update_attributes(raw_cpf_cnpj: result['value'], cpf_cnpj: result['value'].try(:gsub, /\D+/, ''))

    end
  end
end
