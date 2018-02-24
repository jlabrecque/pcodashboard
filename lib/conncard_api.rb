
require 'pco_api'
require 'rubygems'
require 'json'
require 'date'
require 'graticule'
require 'calendar_methods.rb'
require 'dotenv'
require 'dotenv-rails'

@settings = Setting.x

#General Variables


def search_name(fname,lname)
    api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
    fnamelist = JSON.parse(api.people.v2.people.get(where: { search_name: fname }).to_json)["data"]
    lnamelist = JSON.parse(api.people.v2.people.get(where: { search_name: lname }).to_json)["data"]
    fulllist = (fnamelist & lnamelist).uniq
    return fulllist
end


def create_wfcard(wf,pid)
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  api.people.v2.workflows[wf].cards.post(
    data: {
      type: 'WorkflowCard',
      attributes: {
      },
      relationships: {
        person: {
          data: {
            type: "Person",
            id: pid
          }
        }
      }
    }
  )
end

def create_wfcardnote(wfc,pid,notetext)
  api = PCO::API.new(basic_auth_token: @settings.pcoauthtok, basic_auth_secret: @settings.pcoauthsec )
  api.people.v2.people[pid].workflow_cards[wfc].notes.post(
    data: {
      type: 'WorkflowCardNote',
      attributes: {
        note: notetext
      }
    }
  )
end

def create_prayercard(wf,pid,notetext)
  # create a workflow card in the appropriate workflow
  result = create_wfcard(wf,pid)
  wfc = result["data"]["id"]
  # create card note attached to the workflow card just created (based on wfc from result)
  result2 = create_wfcardnote(wfc,pid,notetext)
  final = result2["data"]["id"]
  return final
end
