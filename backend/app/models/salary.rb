class Salary < ApplicationRecord
  belongs_to :employee

  validates :amount,
            numericality: { greater_than: 0 }

  validates :currency_code,
            presence: true,
            format: { with: /\A[A-Z]{3}\z/ }

  validates :effective_from, presence: true

  validate :effective_to_must_not_be_before_effective_from
  validate :salary_period_must_not_overlap

  private

  def effective_to_must_not_be_before_effective_from
    return if effective_from.blank? || effective_to.blank?
    return unless effective_to < effective_from

    errors.add(:effective_to, "cannot be before the effective start date")
  end

  def salary_period_must_not_overlap
    return if employee.nil? || effective_from.blank?

    overlapping_salaries = employee.salaries
      .where("effective_to IS NULL OR effective_to >= ?", effective_from)

    if effective_to.present?
      overlapping_salaries = overlapping_salaries
        .where("effective_from <= ?", effective_to)
    end

    overlapping_salaries = overlapping_salaries.where.not(id: id) if persisted?

    if overlapping_salaries.exists?
      errors.add(:effective_from, "overlaps with an existing salary period")
    end
  end
end