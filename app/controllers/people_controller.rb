class PeopleController < ApplicationController

#  layout 'admin'
    layout 'application'

    before_action :confirm_logged_in

  def index

    @people = Person.where(:people_status => "active").sorted.page(params[:page]).per(25)
    if params[:search]
        @people = Person.search(params[:search]).sorted.page(params[:page]).per(25)
      else
        @people = Person.where(:people_status => "active").sorted.page(params[:page]).per(25)
      end

  end

  def campbell

    @people = Person.campbell.where(:people_status => "active").sorted.page(params[:page]).per(25)
    if params[:search]
        @people = Person.search(params[:search]).campbell.sorted.page(params[:page]).per(25)
      else
        @people = Person.where(:people_status => "active").campbell.sorted.page(params[:page]).per(25)
      end

  end
  def gilroy

    @people = Person.gilroy.where(:people_status => "active").sorted.page(params[:page]).per(25)
    if params[:search]
        @people = Person.search(params[:search]).gilroy.sorted.page(params[:page]).per(25)
      else
        @people = Person.where(:people_status => "active").gilroy.sorted.page(params[:page]).per(25)
      end

  end
  def morganhill

    @people = Person.morganhill.where(:people_status => "active").sorted.page(params[:page]).per(25)
    if params[:search]
        @people = Person.search(params[:search]).morganhill.sorted.page(params[:page]).per(25)
      else
        @people = Person.where(:people_status => "active").morganhill.sorted.page(params[:page]).per(25)
      end

  end
  def sanjose

    @people = Person.sanjose.where(:people_status => "active").sorted.page(params[:page]).per(25)
    if params[:search]
        @people = Person.search(params[:search]).sanjose.sorted.page(params[:page]).per(25)
      else
        @people = Person.where(:people_status => "active").sanjose.sorted.page(params[:page]).per(25)
      end

  end

  def donations

    @people = Person.where(:people_status => "active").sorted.page(params[:page]).per(50)
    if params[:search]
        @people = Person.search(params[:search]).sorted.page(params[:page]).per(50)
      else
        @people = Person.where(:people_status => "active").sorted.page(params[:page]).per(50)
      end

  end
  def dcampbell

    @people = Person.campbell.where(:people_status => "active").sorted.page(params[:page]).per(50)
    if params[:search]
        @people = Person.search(params[:search]).campbell.sorted.page(params[:page]).per(50)
      else
        @people = Person.where(:people_status => "active").campbell.sorted.page(params[:page]).per(50)
      end

  end
  def dmorganhill

    @people = Person.morganhill.where(:people_status => "active").sorted.page(params[:page]).per(50)
    if params[:search]
        @people = Person.search(params[:search]).morganhill.sorted.page(params[:page]).per(50)
      else
        @people = Person.where(:people_status => "active").morganhill.sorted.page(params[:page]).per(50)
      end

  end
  def dgilroy

    @people = Person.gilroy.where(:people_status => "active").sorted.page(params[:page]).per(50)
    if params[:search]
        @people = Person.search(params[:search]).gilroy.sorted.page(params[:page]).per(50)
      else
        @people = Person.where(:people_status => "active").gilroy.sorted.page(params[:page]).per(50)
      end

  end
  def dsanjose

    @people = Person.sanjose.where(:people_status => "active").sorted.page(params[:page]).per(50)
    if params[:search]
        @people = Person.search(params[:search]).sanjose.sorted.page(params[:page]).per(50)
      else
        @people = Person.where(:people_status => "active").sanjose.sorted.page(params[:page]).per(50)
      end

  end

  def show
    @person = Person.find(params[:id])
    @checks = CheckIn.where(:checkin_person =>@person.pco_id)
    @donations = Donation.where(:pco_id => @person.pco_id)
    pid = @person[:pco_id]

    @checkincal = checkin_grid(pid)
    @donationcal = donation_grid(pid)


    data_table_checkin = GoogleVisualr::DataTable.new
        data_table_checkin.new_column('date'  , 'Date')
        data_table_checkin.new_column('number', 'Vol/Att')
        data_table_checkin.add_rows(@checkincal)
    data_table_donation = GoogleVisualr::DataTable.new
        data_table_donation.new_column('date'  , 'Date')
        data_table_donation.new_column('number', 'Vol/Att')
        data_table_donation.add_rows(@donationcal)

        opts   = { :title => "Check-Ins", :width => 800, :height => 300, tooltip: { isHtml: FALSE }, calendar: { cellSize: 13.5 } }
        @chart_checkin = GoogleVisualr::Interactive::Calendar.new(data_table_checkin, opts)

        opts   = { :title => "Donations", :width => 800, :height => 300, tooltip: { isHtml: FALSE }, calendar: { cellSize: 13.5 } }
        @chart_donation = GoogleVisualr::Interactive::Calendar.new(data_table_donation, opts)
=begin
        opts   = { :title => "Volunteering", :width => 800, :height => 300, calendar: { cellSize: 13.5 } }
        @chart3 = GoogleVisualr::Interactive::Calendar.new(data_table, opts)
=end
  end

  def new
    @person = Person.new({:first_name => 'Default', :last_name => 'User'})
  end

  def create
    @person = Person.new(person_params)
    if @person.save
      flash[:notice] = "Person created successfully"
      redirect_to(people_path)
    else
      render('new')
    end
  end

  def edit
    @person = Person.find(params[:id])

  end

  def update
    @person = Person.find(params[:id])

    if @person.update_attributes(person_params)
      flash[:notice] = "Person updated successfully"
      redirect_to(person_path(@person))
    else
      render('edit')
    end

  end

  def delete
    @person = Person.find(params[:id])
  end

  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    flash[:notice] = "Person #{@person.last_name} deleted successfully"
    redirect_to(people_path)
  end



private

  def person_params
    params.require(:person).permit(:pco_id, :first_name, :last_name, :email)
  end

end
