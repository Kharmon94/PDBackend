module Authorization
  extend ActiveSupport::Concern

  def require_admin!
    unless current_user&.admin?
      render json: { error: 'Unauthorized. Admin access required.' }, status: :forbidden
    end
  end

  def require_partner!
    unless current_user&.partner? || current_user&.admin?
      render json: { error: 'Unauthorized. Partner access required.' }, status: :forbidden
    end
  end

  def require_distribution!
    unless current_user&.distribution? || current_user&.admin?
      render json: { error: 'Unauthorized. Distribution partner access required.' }, status: :forbidden
    end
  end

  def require_partner_or_admin!
    require_partner!
  end

  def require_distribution_or_admin!
    require_distribution!
  end
end

