object @task
attributes :id, :project_id
node(:running) { @task.running?(@current_user.id) }
