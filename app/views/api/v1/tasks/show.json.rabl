object @task
attributes :id, :project_id, :source_name, :source_identifier, :current_state, :story_type, :name
node(:running) {|task| task.running?(@current_user.id) }
