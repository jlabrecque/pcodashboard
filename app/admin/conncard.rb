ActiveAdmin.register Conncard do
  require 'csv'
  #actions :index, :show

  menu priority: 6, label: "Connection Cards"
  #  menu parent: "Giving Views"


  # active_admin_import_anything do |file|
  #       raw = ""
  #       header = []
  #       hdr = []
  #       f = File.open(file.path,'r')
  #       linecounter = 0
  #       f.each_line do |line|
  #           if !line.match("<pre>") #not leading 2 lines
  #               raw += line
  #               if linecounter == 0
  #                 hdr = line.split(",")
  #               end
  #               linecounter += 1
  #           end
  #       end
  #       csvhash = CSV.new(raw, headers: true).map(& :to_hash)
  #       hdr.each do |h|
  #         header << { h.delete("\n").delete("\r") => ""}
  #       end
  #       week_of = csvhash.last["Week_Of"]
  #       new = Conncsv.create(:week_of => week_of, :header => header, :cards => csvhash, :cardcount => (linecounter - 1), :columncount => header.count)
  # end

  ## Index Batch Actions
  # batch_action :match, form: {
  #   header: [inputs[:header]]
  #   } do |ids, inputs|
  #   redirect_to collection_path, notice: [ids, inputs].to_s
  #   # ...
  # end


  index do
    selectable_column
    column :week_of
    column :header
    column :columncount
    column :cardcount
    actions
  end


  filter :week_of, as: :select

end
