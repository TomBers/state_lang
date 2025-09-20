defmodule StateLangWeb.BasicTodoLiveTest do
  use StateLangWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @path "/basic_todo"
  @form_selector "form[phx-submit='add_todo']"
  @input_selector "#todo_form_text"

  test "renders page" do
    {:ok, _lv, html} = live(build_conn(), @path)
    assert html =~ "Basic Todo List Template"
  end

  test "form resets after submit and ignores stale change events" do
    {:ok, lv, _html} = live(build_conn(), @path)

    # Initial state: input should be empty
    assert has_element?(lv, "input#{@input_selector}[value='']")

    # Type "First" into the input (change event)
    form = form(lv, @form_selector, %{"todo_form" => %{"text" => "First"}})
    _ = render_change(form)

    # Ensure the input reflects the changed value before submit
    assert has_element?(lv, "input#{@input_selector}[value='First']")

    # Submit the form
    submit_html = render_submit(form)

    # The page should display the new todo and the input should be cleared
    assert submit_html =~ "First"
    assert has_element?(lv, "input#{@input_selector}[value='']")

    # Simulate a stale change event sent by the browser right after submit with the same params
    _ = render_change(form)

    # Ensure the stale change did not repopulate the input
    assert has_element?(lv, "input#{@input_selector}[value='']")

    # Now type a new value "Second" and ensure it appears in the input before submit
    form2 = form(lv, @form_selector, %{"todo_form" => %{"text" => "Second"}})
    _ = render_change(form2)
    assert has_element?(lv, "input#{@input_selector}[value='Second']")

    # Submit the second todo
    submit_html2 = render_submit(form2)

    # BasicTodo prepends new todos; display is joined with commas.
    # So the display order should be "Second,First"
    assert submit_html2 =~ "Second,First"

    # Input should be cleared again after the second submit
    assert has_element?(lv, "input#{@input_selector}[value='']")
  end
end
