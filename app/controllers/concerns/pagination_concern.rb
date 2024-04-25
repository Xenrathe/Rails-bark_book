module PaginationConcern
  extend ActiveSupport::Concern

  def paginate_collection(collection, per_page = 10)
    @page = params[:page].present? ? params[:page].to_i : 1
    total_pages = (collection.size.to_f / per_page).ceil

    if collection.is_a?(ActiveRecord::Base)
      paginated_collection = collection.limit(per_page).offset(per_page * (@page - 1))
    else
      paginated_collection = collection.slice((@page - 1) * per_page, per_page)
    end

    [paginated_collection, total_pages]
  end
end