# frozen_string_literal: true

require "spec_helper"

describe Decidim::EventPublisherJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "events"
    end
  end

  describe "perform" do
    subject do
      described_class.perform_now(event_name, data)
    end

    let(:event_name) { "some_event" }
    let(:data) do
      {
        resource:,
        event_class:
      }
    end
    let(:event_class) { "Decidim::Dev::DummyResourceEvent" }

    context "when the resource is publicable" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = nil
        end

        it "does not enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end

        context "when #force_send is true" do
          before do
            data[:force_send] = true
          end

          it "enqueues the jobs without checking if the resource is published" do
            expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
            expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

            subject
          end
        end
      end
    end

    context "when there is a component" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
          resource.component.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = Time.current
          resource.component.published_at = nil
        end

        it "does not enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end
      end
    end

    context "when there is a participatory space" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
          resource.component.participatory_space.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = Time.current
          resource.component.participatory_space.published_at = nil
        end

        it "does not enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end
      end
    end

    context "when the resource is a component" do
      let(:resource) { build(:component) }

      it "enqueues the jobs" do
        expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
        expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

        subject
      end

      context "when it is not published" do
        let(:resource) { build(:component, :unpublished) }

        it "does not enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end
      end
    end

    context "when the resource is a participatory space" do
      let(:resource) { build(:participatory_process) }

      it "enqueues the jobs" do
        expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
        expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

        subject
      end

      context "when it is not published" do
        let(:resource) { build(:participatory_process, :unpublished) }

        it "does not enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end
      end
    end

    context "when the event is not present" do
      let(:resource) { build(:dummy_resource, :published) }
      let(:event_class) { nil }

      it "does not enqueue the jobs" do
        expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
        expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

        subject
      end
    end

    context "when the event class does not send emails" do
      let(:resource) { build(:dummy_resource, :published) }

      before do
        allow(Decidim::Dev::DummyResourceEvent).to receive(:types).and_return([:notification])
      end

      it "does not enqueue the email job" do
        expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
        expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

        subject
      end
    end

    context "when the event class does not send notifications" do
      let(:resource) { build(:dummy_resource, :published) }

      before do
        allow(Decidim::Dev::DummyResourceEvent).to receive(:types).and_return([:email])
      end

      it "does not enqueue the notification job" do
        expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
        expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

        subject
      end
    end
  end
end
