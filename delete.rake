namespace :update do
  task :cpf_cnpj => :environment do
    query = <<-SQL
        select hex(account_id) account_id,
        count(*) qtd
        from account_informations
        where `key`= 'cpf' or `key`= 'cnpj'
        group by account_id
        having qtd > 1
    SQL

    results = ActiveRecord::Base.connection.exec_query(query).to_hash

    binding.pry
    results.each do |result|
      account = Account.find(result["account_id"])

      if account.individual_entity? #cpf
        AccountInformation.where(account_id: account.id, key: 'cnpj').delete_all

        cpf = AccountInformation.where(account_id: account.id, key: 'cpf')
        cpf.last.delete if cpf.size > 1
      elsif account.legal_entity? #cnpj
        AccountInformation.where(account_id: account.id, key: 'cpf').delete_all

        cnpj = AccountInformation.where(account_id: account.id, key: 'cnpj')
        cnpj.last.delete if cpf.size > 1
      else
        puts "Não atualizei #{result}"
      end
    end
  end
end
