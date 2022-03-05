# bootstrap-editable-rails.js.coffee
# Modify parameters of X-editable suitable for Rails.

jQuery ($) ->
  EditableForm = $.fn.editableform.Constructor
  unless EditableForm::saveWithUrlHook?
    EditableForm::saveWithUrlHook = (value) ->
      originalUrl = @options.url
      resource = @options.resource
      @options.url = (params) =>
        # TODO: should not send when create new object
        if typeof originalUrl == 'function' # user's function
          originalUrl.call(@options.scope, params)
        else if originalUrl? && @options.send != 'never'
          # send ajax to server and return deferred object
          obj = {}
          obj[params.name] = params.value
          # support custom inputtypes (eg address)
          if resource
            params[resource] = obj
          else
            params = obj
          delete params.name
          delete params.value
          delete params.pk

          # replacer is a function that looks for empty
          # arrays and replaces them with an array with an empty
          # string. 

          # We need to do this because ajax will strip out any values (and their keys)
          # that is considers empty. This would include an empty array. So what would have
          # been an object like { school: { home_page_sections: [] }} becomes just {}
          # which rails won't know what to do with. 

          replacer =(key, value) -> 
            if Array.isArray(value) && value.length == 0
              [''] 
            else 
              value
          params = JSON.parse(JSON.stringify(params, replacer))

          $.ajax($.extend({
            url     : originalUrl
            data    : params
            type    : 'PUT' # TODO: should be 'POST' when create new object
            dataType: 'json'
          }, @options.ajaxOptions))
      @saveWithoutUrlHook(value)
    EditableForm::saveWithoutUrlHook = EditableForm::save
    EditableForm::save = EditableForm::saveWithUrlHook
