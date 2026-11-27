class Employee < ApplicationRecord
  belongs_to :country
  belongs_to :department
  has_many :salaries, dependent: :restrict_with_error

  EMPLOYMENT_STATUSES = %w[active inactive].freeze

  validates :employee_number, presence: true, uniqueness: true
  validates :first_name, :last_name, :job_title, presence: true
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employment_status, inclusion: { in: EMPLOYMENT_STATUSES }
end
