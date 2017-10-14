define ['require'], ->
  require ['app'], ->
    deleteTrip = (id) ->
    $.ajax
      method: 'post'
      url: '/admin/trip/delete/' + id
      success: (data) ->
        if data.success
          console.log("successfully deleted trip.")
      error: (err) ->
        console.log(err)
