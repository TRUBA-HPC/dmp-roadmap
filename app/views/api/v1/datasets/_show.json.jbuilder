# frozen_string_literal: true

# locals: plan

presenter = Api::V1::PlanPresenter.new(plan: plan)

json.title "Generic Dataset"
json.personal_data "unknown"
json.sensitive_data "unknown"

json.dataset_id do
  json.partial! "api/v1/identifiers/show", identifier: presenter.identifier
end

json.distribution [plan] do |distribution|
  json.title "PDF - #{distribution.title}"
  json.data_access "open"
  json.download_url plan_export_url(distribution, format: :pdf)
  json.format do
    json.array! ["application/pdf"]
  end
end

if plan.research_domain_id.present?
  research_domain = ResearchDomain.find_by(id: plan.research_domain_id)
  if research_domain.present?
    json.keyword [research_domain.label, "#{research_domain.identifier} - #{research_domain.label}"]
  end
end
