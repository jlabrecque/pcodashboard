require 'rubygems'
require 'json'
require 'pp'
require 'csv'
require 'pcocore_api.rb'

#CONSTANTS
offset_index = 0
page_size = 50
sleepval = 30
totwfcreated = 0
totwfupdated = 0
totwfscreated = 0
totwfsupdated = 0
totwfccreated = 0
totwfcupdated = 0

$pullcount = 0
next_check = 0

#Start ...
puts "Starting processing..."

# #if next exists (not at end)...
#   while !next_check.nil?
#     # pull groups of records each loop
#     workflowblock = workflows(page_size,offset_index)
#     next_check = workflowblock["links"]["next"]
#     workflowblock["data"].each do |wf|
#       workflow_id_pco               = wf["id"]
#       workflow_name                 = wf["attributes"]["name"]
#       workflow_completed_cards      = wf["attributes"]["completed_card_count"]
#       workflow_ready_cards          = wf["attributes"]["total_ready_card_count"]
#       workflow_created_at           = wf["attributes"]["created_at"]
#       workflow_updated_at           = wf["attributes"]["updated_at"]
#       workflowcheck = Workflow.where(:workflow_id_pco => workflow_id_pco)
#       if !workflowcheck.exists?
#         puts "Creating new Workflow #{workflow_id_pco}"
#         wfnew = Workflow.create(
#             :workflow_id_pco              => workflow_id_pco,
#             :workflow_name                => workflow_name,
#             :workflow_completed_cards     => workflow_completed_cards,
#             :workflow_ready_cards         => workflow_ready_cards,
#             :workflow_created_at          => workflow_created_at,
#             :workflow_updated_at          => workflow_updated_at
#             )
#         wfid = wfnew.id
#         totwfcreated =+ 1
#       elsif !(workflowcheck[0].workflow_updated_at == wf["attributes"]["updated_at"])
#         puts "Updating Workflow #{workflow_id_pco}"
#         wfnew = Workflow.update(workflowcheck[0]["id"],
#             :workflow_id_pco              => workflow_id_pco,
#             :workflow_name                => workflow_name,
#             :workflow_completed_cards     => workflow_completed_cards,
#             :workflow_ready_cards         => workflow_ready_cards,
#             :workflow_created_at          => workflow_created_at,
#             :workflow_updated_at          => workflow_updated_at
#             )
#         wfid = workflowcheck[0]["id"]
#         totwfupdated =+ 1
#       else
#         puts "No actions for Workflow #{workflow_id_pco}"
#         wfid = workflowcheck[0]["id"]
#       end
#
#       #Create Workflow Step records
#      wf["relationships"]["steps"]["data"].each do |step|
#       workflowstepcheck = Workflowstep.where(:workflow_id_pco => workflow_id_pco, :workflowstep_id_pco => step["id"])
#       if workflowstepcheck.count < 1
#         puts "Creating new Workflowstep"
#         wfstep = Workflowstep.create(
#           :workflow_id            => wfid,
#           :workflow_id_pco        => workflow_id_pco,
#           :workflowstep_id_pco    => step["id"]
#         )
#         totwfscreated += 1
#       elsif !workflowstepcheck[0]["updated_at"] == wf["attributes"]["updated_at"]
#         puts "Creating new Workflowstep"
#         wfstep = Workflowstep.update(workflowstepcheck[0]["id"],
#           :workflow_id            => wfid,
#           :workflow_id_pco        => workflow_id_pco,
#           :workflowstep_id_pco    => step["id"]
#         )
#         totwfsupdated += 1
#       else
#         puts "No action"
#       end
#     end
#
#     end
#     offset_index += page_size
# end
#
# #Create Workflow Card records
# Workflow.all.each do |wf|
#   offset_index = 0
#   page_size = 50
#   next_check = 0
#     while !next_check.nil?
#       wfcblock = workflowcards(wf.workflow_id_pco,page_size,offset_index)
#       next_check = wfcblock["links"]["next"]
#       wfcblock["data"].each do |wfc|
#         workflowcardcheck = Workflowcard.where(:workflow_id_pco => wfc["relationships"]["workflow"]["data"]["id"], :workflowcard_id_pco => wfc["id"])
#         !wfc["relationships"]["assignee"]["data"].nil? ? assignee = wfc["relationships"]["assignee"]["data"]["id"] : assignee = ""
#         !wfc["relationships"]["person"]["data"].nil? ? prs = wfc["relationships"]["person"]["data"]["id"] : prs = ""
#               if workflowcardcheck.count < 1
#                 puts "Creating new Workflowcard #{wfc["id"]}"
#                 wfstep = Workflowcard.create(
#                   :workflow_id                  => wf.id,
#                   :workflow_id_pco              => wfc["relationships"]["workflow"]["data"]["id"],
#                   :workflowcard_id_pco          => wfc["id"],
#                   :workflowcard_stage           => wfc["attributes"]["stage"],
#                   :workflowcard_assignee        => assignee,
#                   :workflowcard_person_id_pco   => prs,
#                   :workflowcard_completed_at    => wfc["attributes"]["completed_at"],
#                   :workflowcard_created_at      => wfc["attributes"]["created_at"],
#                   :workflowcard_updated_at      => wfc["attributes"]["updated_at"]
#                 )
#                 totwfccreated += 1
#               elsif !workflowcardcheck[0]["updated_at"] == wfc["attributes"]["updated_at"]
#                 puts "Updating Workflowcard  #{wfc["id"]}"
#                 wfstep = Workflowcard.update(workflownotecheck[0]["id"],
#                   :workflow_id                  => wf.id,
#                   :workflow_id_pco              => wfc["relationships"]["workflow"]["data"]["id"],
#                   :workflowcard_id_pco          => wfc["id"],
#                   :workflowcard_stage           => wfc["attributes"]["stage"],
#                   :workflowcard_assignee        => wfc["relationships"]["assignee"]["data"]["id"],
#                   :workflowcard_person_id_pco   => wfc["relationships"]["person"]["data"]["id"],
#                   :workflowcard_completed_at    => wfc["attributes"]["completed_at"],
#                   :workflowcard_created_at      => wfc["attributes"]["created_at"],
#                   :workflowcard_updated_at      => wfc["attributes"]["updated_at"]
#                 )
#                 totwfcupdated += 1
#               else
#                 puts "No action for Workflowcard  #{wfc["id"]}"
#               end
#         end
#   offset_index += page_size
#   end
# end

Workflowcard.all.each do |wfc|
  puts "Processing Workflow #{wfc.workflow_id_pco} Workflowcard #{wfc.workflowcard_id_pco}"
  offset_index = 0
  page_size = 50
  wfcn = workflowcardnotes(wfc.workflow_id_pco,wfc.workflowcard_id_pco,page_size,offset_index)["data"]
  wfcn.each do |w|
      workflowcardnotecheck = Workflowcardnote.where(:workflowcardnote_id_pco => w["id"])
      if workflowcardnotecheck.count < 1
        puts "--Creating new Workflowcardnote #{w["id"]}"
          wfcnstep = Workflowcardnote.create(
            :workflowcard_id                  => wfc.id,
            :workflowcard_id_pco              => wfc.workflowcard_id_pco,
            :workflowcardnote_id_pco          => w["id"],
            :workflowcard_note                => w["attributes"]["note"].force_encoding("UTF-8"),
            :workflowcard_created_at          => w["attributes"]["created_at"]
          )
      else
        puts "---Updating Workflowcardnote  #{w["id"]}"

          wfcnstep = Workflowcardnote.update(workflowcardnotecheck[0]["id"],
            :workflowcard_id                  => wfc.id,
            :workflowcard_id_pco              => wfc.workflowcard_id_pco,
            :workflowcardnote_id_pco          => w["id"],
            :workflowcard_note                => w["attributes"]["note"].force_encoding("UTF-8"),
            :workflowcard_created_at          => w["attributes"]["created_at"]
          )

      end

  end
end




# Workflowcard.all.each do |wfc|
#     prs = Person.where(:pco_id => wfc.workflowcard_person_id_pco)
#     if prs.count > 0
#       puts "Updating Workflow Person_id association #{wfc.id}"
#       wfc.update(:person_id => prs[0].id)
#     end
# end
# puts "=============================================="
# puts "** All records processed  **"
# puts "Total Workflows Created: #{totwfcreated}"
# puts "Total Workflows Updated: #{totwfupdated}"
# puts "Total Workflow Steps Created: #{totwfscreated}"
# puts "Total Workflow Steps Updated: #{totwfsupdated}"
# puts "Total Workflow Cards Created: #{totwfccreated}"
# puts "Total Workflow Cards Updated: #{totwfcupdated}"
