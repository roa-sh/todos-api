class TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo, only: [:show, :update, :destroy]

  # GET /todos
  def index
    @todos = Todo.all
    # json_response(@todos)
    render json: @todos, each_serializer: TodoSerializer
  end

  # POST /todos
  def create
    @todo = Todo.create!(todo_params)
    json_response(@todo, :created)
  end

  # GET /todos/:id
  def show
    # json_response(@todo) # todo declared in private methods}
    render json: @todo, serializer: TodoSerializer
  end

  # PUT /todos/:id
  def update
    @todo.update(todo_params)
    head :no_content
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy
    head :no_content
  end

  private
  # whitelist the params
  def todo_params
    params.permit(:title, :created_by) # require(:todo).
  end

  # obtaining todo by id
  def set_todo
    @todo = Todo.find(params[:id])
  end

end
