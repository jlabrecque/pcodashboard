class CreateWorkflowcardnotes < ActiveRecord::Migration[5.0]
def self.up
    create_table :workflowcardnotes, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.integer "workflowcard_id"
    t.string "workflowcard_id_pco"
    t.string "workflowcardnote_id_pco"
    t.longtext "workflowcard_note"
    t.string "workflowcard_created_at"
    t.timestamps
    end
  end
  def self.down
    drop_table :workflowcardnotes
    end
end
