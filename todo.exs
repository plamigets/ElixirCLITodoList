defmodule Todo do
  @filename "to_do.txt"

  defstruct id: 0, task: "", done: false

  def start do
    loop()
  end

  defp loop do
    IO.puts("\nSelect an option:")
    IO.puts("1. Add new task")
    IO.puts("2. Delete task")
    IO.puts("3. Show all tasks")
    IO.puts("4. Mark task as done")
    IO.puts("5. Filter tasks")
    IO.puts("6. Edit task")
    IO.puts("7. Show statistics")
    IO.puts("8. Exit")

    input = IO.gets("> ") |> String.trim()

    case input do
      "1" ->
        IO.puts("-------------------------------------------")
        add_task()
        loop()

      "2" ->
        IO.puts("-------------------------------------------")
        delete_task()
        loop()

      "3" ->
        IO.puts("-------------------------------------------")
        show_tasks()
        loop()

      "4" ->
        IO.puts("-------------------------------------------")
        mark_task_done()
        loop()

      "5" ->
        IO.puts("-------------------------------------------")
        filter_tasks()
        loop()

      "6" ->
        IO.puts("-------------------------------------------")
        edit_task()
        loop()

      "7" ->
        IO.puts("-------------------------------------------")
        show_statistics()
        loop()

      "8" ->
        IO.puts("Exit... Byyeeee!")

      _ ->
        IO.puts("Invalid option.")
        loop()
    end
  end

  defp read_file do
    if not File.exists?(@filename), do: File.write!(@filename, "")

    case File.read(@filename) do
      {:ok, content} ->
        content
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          [id, task, done] = String.split(line, ",")
          %Todo{id: String.to_integer(id), task: task, done: parse_boolean(done)}
        end)

      {:error, _} -> []
    end
  end

  defp write_file(tasks) do
    content =
      Enum.map(tasks, fn %Todo{id: i, task: t, done: d} ->
        "#{i},#{t},#{d}"
      end)
      |> Enum.join("\n")

    File.write!(@filename, content)
  end

  defp add_task do
    IO.puts("Enter task description:")
    task = IO.gets("> ") |> String.trim()
    tasks = read_file()

    case Enum.find(tasks, fn t -> t.task == task end) do
      nil ->
        new_id = if tasks == [], do: 1, else: Enum.max_by(tasks, & &1.id).id + 1
        new_task = %Todo{id: new_id, task: task, done: false}
        write_file([new_task | tasks])
        IO.puts("Task added with ID #{new_id}.")

      _ ->
        IO.puts("Task already exists!")
    end
  end

  defp delete_task do
    tasks = read_file()

    if Enum.empty?(tasks) do
      IO.puts("No tasks to delete.")
    else
      show_tasks()
      IO.puts("Enter task ID to delete:")
      id_input = IO.gets("> ") |> String.trim()

      case Integer.parse(id_input) do
        {id, ""} ->
          new_tasks = Enum.reject(tasks, fn t -> t.id == id end)
          if length(new_tasks) < length(tasks) do
            write_file(new_tasks)
            IO.puts("Task deleted.")
          else
            IO.puts("No task found with that ID.")
          end

        _ -> IO.puts("Invalid input.")
      end
    end
  end

  defp show_tasks do
    tasks = read_file()

    if Enum.empty?(tasks) do
      IO.puts("No tasks found.")
    else
      Enum.each(tasks, fn t ->
        status = if t.done, do: "Done", else: "Pending"
        IO.puts("ID: #{t.id} | #{t.task} [#{status}]")
      end)
    end
  end

  defp mark_task_done do
    show_tasks()
    IO.puts("Enter task ID to mark as done:")
    id_input = IO.gets("> ") |> String.trim()

    case Integer.parse(id_input) do
      {id, ""} ->
        tasks = read_file()
        case Enum.find(tasks, fn t -> t.id == id end) do
          nil -> IO.puts("Task not found.")
          task_to_update ->
            updated = %Todo{task_to_update | done: true}
            new_list = Enum.map(tasks, fn t -> if t.id == id, do: updated, else: t end)
            write_file(new_list)
            IO.puts("Task marked as done.")
        end

      _ -> IO.puts("Invalid input.")
    end
  end

  defp filter_tasks do
    IO.puts("Filter by:")
    IO.puts("1. Pending tasks")
    IO.puts("2. Completed tasks")

    input = IO.gets("> ") |> String.trim()
    tasks = read_file()

    filtered =
      case input do
        "1" -> Enum.filter(tasks, fn t -> not t.done end)
        "2" -> Enum.filter(tasks, fn t -> t.done end)
        _ -> IO.puts("Invalid filter."); []
      end

    Enum.each(filtered, fn t ->
      status = if t.done, do: "Done", else: "Pending"
      IO.puts("ID: #{t.id} | #{t.task} [#{status}]")
    end)
  end

  defp edit_task do
    show_tasks()
    IO.puts("Enter task ID to edit:")
    id_input = IO.gets("> ") |> String.trim()

    case Integer.parse(id_input) do
      {id, ""} ->
        tasks = read_file()
        case Enum.find(tasks, fn t -> t.id == id end) do
          nil -> IO.puts("Task not found.")
          task_to_edit ->
            IO.puts("Enter new description:")
            new_desc = IO.gets("> ") |> String.trim()
            updated_task = %Todo{task_to_edit | task: new_desc}
            updated_list = Enum.map(tasks, fn t -> if t.id == id, do: updated_task, else: t end)
            write_file(updated_list)
            IO.puts("Task updated.")
        end

      _ -> IO.puts("Invalid input.")
    end
  end

  defp show_statistics do
    tasks = read_file()
    total = length(tasks)
    done = Enum.count(tasks, fn t -> t.done end)
    pending = total - done

    IO.puts("Total tasks: #{total}")
    IO.puts("Completed: #{done}")
    IO.puts("Pending: #{pending}")
  end

  defp parse_boolean(str) do
    case String.trim(str) do
      "true" -> true
      "false" -> false
      _ -> false
    end
  end
end

Todo.start()
