object @task
attributes :id
node(:running) { @task.running?(@current_user.id) }
