require 'rails_helper'

RSpec.describe "Todos", type: :request do
  # initialize test data
  let!(:todos) { create_list(:todo, 10) }
  let!(:todo_id) { todos.first.id }
  before(:each) do
    @user =  FactoryBot.create(:user) 
    @sign_in_url = '/auth/sign_in' 
    @sign_out_url = '/auth/sign_out'
    @login_params = {
        email: @user.email,
        password: @user.password
    }
    post @sign_in_url, params: @login_params, as: :json
    @headers = {
      'uid' => response.headers['uid'],
      'client' => response.headers['client'],
      'access-token' => response.headers['access-token']
    }
  end
  describe 'POST /api/v1/auth/sign_in' do
    context 'when login params is valid' do
      # before do
      #   post @sign_in_url, params: @login_params, as: :json
      # end
      it 'returns status 200' do
        expect(response).to have_http_status(200)
      end
      it 'returns access-token in authentication header' do
        expect(@headers['access-token']).to be_present
      end
    end
  end
  # Test suite for GET /todos
  describe "GET /todos" do
    # make HTTP get request before each example
    before { get '/todos', headers: @headers }

    it 'returns todos' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /todos/:id' do

    before { get "/todos/#{todo_id}", headers: @headers }
    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record doesn\'t exists' do
      let(:todo_id) {100}
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a Not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /todos' do
    # valid payload
    let(:valid_attributes){ { title: 'Learn Elm', created_by: '1' } }

    context 'when the request is valid' do 
      before { post '/todos', params: valid_attributes, headers: @headers }
      
      it 'creates a todo' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/todos', params: {title: 'Foobar'}, headers: @headers }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a valid failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /todos/:id' do
    let(:valid_attributes) { {title: 'Shopping'} }
    
    context 'when the record exists' do
      before { put "/todos/#{todo_id}", params: valid_attributes, headers: @headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /todos/:id' do
    before { delete "/todos/#{todo_id}", headers: @headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
