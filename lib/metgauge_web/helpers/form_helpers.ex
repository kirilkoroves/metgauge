defmodule MetgaugeWeb.Helpers.FormHelpers do
  require Logger
  use Phoenix.Component

  import Phoenix.HTML.Tag, only: [content_tag: 3]
  import Phoenix.HTML.Form

  def fancy_select(form, field, options, placeholder \\ "") do
    component(
      "Select",
      %{ initialkey: input_value(form, field), options: options },
      %{ fieldname: input_name(form, field), placeholder: placeholder }
      )
  end

  def custom_select(form, field, options, _placeholder \\ "") do
    field_name = input_name(form, field)
    select = Phoenix.HTML.Tag.content_tag(:select, name: field_name, class: "fancy-select") do
      for option <- options do
        Phoenix.HTML.Tag.content_tag(:option, option[:value], value: option[:key], class: "fancy-option")
      end
    end
    select
  end



  def fancy_select_with_initial_key(form, field, options, placeholder, initial_value) do
    component(
      "Select",
      %{ initialkey: initial_value, options: options },
      %{ fieldname: input_name(form, field), placeholder: placeholder }
      )
  end

  def multi_select(form, field, options) do
    component(
      "MultiSelect",
      %{ initial: input_value(form, field), options: options },
      %{ fieldname: input_name(form, field) <> "[]" }
    )
  end

  def tab_radio(form, field, options) do
    component(
      "TabRadio",
      %{ initialkey: input_value(form, field), options: options },
      %{ fieldname: input_name(form, field) }
    )
  end

  def money_input(form, field) do
    initial = case input_value(form, field) do
                %Money{ amount: amount, currency: currency } ->
                  %{ amount: amount, currency: currency}
                nil ->
                  nil
              end
    component(
      "MoneyInput",
      %{ initial: initial },
      %{ fieldname: input_name(form, field) }
    )
  end

  def markdown_editor(form, field) do
    component(
      "MarkdownEditor",
      %{ initial: input_value(form, field) },
      %{ fieldname: input_name(Form, field) })
  end

  def component(component_name, json_props, string_props) do
    props = json_props
    |> Enum.map(fn {k, v} -> {"json.#{k}", Jason.encode!(v)} end)
    |> Enum.into(string_props)
    |> Enum.map(fn {k, v} -> {"data-#{k}", v} end)

    content_tag(:div, "", [
          {"class", "component-container"},
          {"data-component", component_name}
          | props])
  end

end
