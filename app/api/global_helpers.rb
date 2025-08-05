module GlobalHelpers
  include Pagy::Backend
  def present_success(data = {}, message = "Success", status: 200)
    status(status)
    { status: "success", message: message, data: data }
  end


  def present_error(message = "Something went wrong", code: 500)
    error!({
      status: "error",
      message: message
    }, code)
  end

  def paginate(collection, page:, limit:)
    pagy, records = pagy(collection, page: page, limit: limit)
    [ pagy, records ]
  end

  def present_paginated_success(collection, pagy, message = "Success", status: 200)
    status(status)
    {
      status: "success",
      message: message,
      data: collection,
      pagination: {
        page: pagy.page,
        items: pagy.limit,
        count: pagy.count,
        pages: pagy.pages
      }
    }
  end
end
