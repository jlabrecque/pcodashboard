class PersonGridAdds < ActiveRecord::Migration[5.0]
  def self.up
    add_column(:people, :week1, :string)
    add_column(:people, :week1checkin, :string)
    add_column(:people, :week1gift, :string)

    add_column(:people, :week2, :string)
    add_column(:people, :week2checkin, :string)
    add_column(:people, :week2gift, :string)

    add_column(:people, :week3, :string)
    add_column(:people, :week3checkin, :string)
    add_column(:people, :week3gift, :string)

    add_column(:people, :week4, :string)
    add_column(:people, :week4checkin, :string)
    add_column(:people, :week4gift, :string)

    add_column(:people, :week5, :string)
    add_column(:people, :week5checkin, :string)
    add_column(:people, :week5gift, :string)

    add_column(:people, :week6, :string)
    add_column(:people, :week6checkin, :string)
    add_column(:people, :week6gift, :string)

    add_column(:people, :week7, :string)
    add_column(:people, :week7checkin, :string)
    add_column(:people, :week7gift, :string)

    add_column(:people, :week8, :string)
    add_column(:people, :week8checkin, :string)
    add_column(:people, :week8gift, :string)

    add_column(:people, :week9, :string)
    add_column(:people, :week9checkin, :string)
    add_column(:people, :week9gift, :string)

    add_column(:people, :week10, :string)
    add_column(:people, :week10checkin, :string)
    add_column(:people, :week10gift, :string)

    add_column(:people, :week11, :string)
    add_column(:people, :week11checkin, :string)
    add_column(:people, :week11gift, :string)

    add_column(:people, :week12, :string)
    add_column(:people, :week12checkin, :string)
    add_column(:people, :week12gift, :string)

    add_column(:people, :week13, :string)
    add_column(:people, :week13checkin, :string)
    add_column(:people, :week13gift, :string)

    add_column(:people, :week14, :string)
    add_column(:people, :week14checkin, :string)
    add_column(:people, :week14gift, :string)

    add_column(:people, :week15, :string)
    add_column(:people, :week15checkin, :string)
    add_column(:people, :week15gift, :string)

    add_column(:people, :week16, :string)
    add_column(:people, :week16checkin, :string)
    add_column(:people, :week16gift, :string)

    add_column(:people, :week17, :string)
    add_column(:people, :week17checkin, :string)
    add_column(:people, :week17gift, :string)

    add_column(:people, :week18, :string)
    add_column(:people, :week18checkin, :string)
    add_column(:people, :week18gift, :string)
  end
  def self.down
    remove_column(:people, :week1)
    remove_column(:people, :week1checkin)
    remove_column(:people, :week1gift)

    remove_column(:people, :week2)
    remove_column(:people, :week2checkin)
    remove_column(:people, :week2gift)

    remove_column(:people, :week3)
    remove_column(:people, :week3checkin)
    remove_column(:people, :week3gift)

    remove_column(:people, :week4)
    remove_column(:people, :week4checkin)
    remove_column(:people, :week4gift)

    remove_column(:people, :week5)
    remove_column(:people, :week5checkin)
    remove_column(:people, :week5gift)

    remove_column(:people, :week6)
    remove_column(:people, :week6checkin)
    remove_column(:people, :week6gift)

    remove_column(:people, :week7)
    remove_column(:people, :week7checkin)
    remove_column(:people, :week7gift)

    remove_column(:people, :week8)
    remove_column(:people, :week8checkin)
    remove_column(:people, :week8gift)

    remove_column(:people, :week9)
    remove_column(:people, :week9checkin)
    remove_column(:people, :week9gift)

    remove_column(:people, :week10)
    remove_column(:people, :week10checkin)
    remove_column(:people, :week10gift)

    remove_column(:people, :week11)
    remove_column(:people, :week11checkin)
    remove_column(:people, :week11gift)

    remove_column(:people, :week12)
    remove_column(:people, :week12checkin)
    remove_column(:people, :week12gift)

    remove_column(:people, :week13)
    remove_column(:people, :week13checkin)
    remove_column(:people, :week13gift)

    remove_column(:people, :week14)
    remove_column(:people, :week14checkin)
    remove_column(:people, :week14gift)

    remove_column(:people, :week15)
    remove_column(:people, :week15checkin)
    remove_column(:people, :week15gift)

    remove_column(:people, :week16)
    remove_column(:people, :week16checkin)
    remove_column(:people, :week16gift)

    remove_column(:people, :week17)
    remove_column(:people, :week17checkin)
    remove_column(:people, :week17gift)

    remove_column(:people, :week18)
    remove_column(:people, :week18checkin)
    remove_column(:people, :week18gift)
  end


end
