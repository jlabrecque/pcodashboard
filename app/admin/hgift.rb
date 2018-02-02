ActiveAdmin.register Hgift do

  menu parent: "Giving Views", label: "Household Giving Report"
  actions :index

  ## Index Batch Actions
      batch_action :email, form: {
        to: %w[CheckedRecords Yourself],
        subject:  :text,
        content:  :textarea,
        copy:  :checkbox
      } do |ids, inputs|
        response = email_selected_hgift(ids,inputs)
        # inputs is a hash of all the form fields you requested
        # redirect_to collection_path, notice: [ids, inputs].to_s
        redirect_to collection_path, notice: response
      end

    index :title => 'Household Giving' do
      render :partial => "hgiftheader"
        selectable_column
        column :campus
        column :family
        # number_column :amount, as: :currency, unit: "$", separator: ","
        number_column "#{Hgift.first.month1}",:month1gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month2}",:month2gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month3}",:month3gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month4}",:month4gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month5}",:month5gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month6}",:month6gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month7}",:month7gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month8}",:month8gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month9}",:month9gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month10}",:month10gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month11}",:month11gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
        number_column "#{Hgift.first.month12}",:month12gift, sortable: false, as: :currency, unit: "$", separator: ".", precision: 0
    end

    filter :last_name
    filter :first_name
    filter :campus, as: :select, label: "Campus"
    filter :family, as: :select, label: "Family"
    filter :annavg, label: "Annual Average Giving"
    filter :lastqtravg, label: "Last Qtr Giving"

end
