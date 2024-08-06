# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe RejectedCoauthorshipEvent do
      let(:resource) { create(:proposal) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:resource_title) { decidim_sanitize_translated(resource.title) }
      let(:event_name) { "decidim.events.proposals.rejected_coauthorship" }

      let(:notification_title) do
        "You have declined the invitation from <a href=\"/profiles/#{author.nickname}\">#{author.name}</a> to become a co-author of the proposal <a href=\"#{resource_path}\">#{resource_title}</a>."
      end

      include_context "when a simple event"
      it_behaves_like "a simple event notification"
      it_behaves_like "a notification event only"
    end
  end
end
