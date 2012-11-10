require 'spec_helper'

describe MoviesController do
  describe 'search movies by director' do

    it 'should call find_by_id' do
      m=mock('Movie')
      m.stub(:director).and_return('George Lucas')
      #Movie.stub(:find_all_by_director)
      Movie.should_receive(:find_by_id).with('1').and_return(m)
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should call movie.director' do
      m=mock('Movie')
      Movie.stub(:find_by_id).and_return(m)
      m.should_receive(:director).and_return('George Lucas')
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should call find_all_by_director' do
      m=mock('Movie')
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.should_receive(:find_all_by_director).with('George Lucas')
      get :search_same_director_movies, {:search_terms => '1'}
    end

    it 'should assign find_all_by_director results to an instance variable' do
      m=mock('Movie')
      fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.stub(:find_all_by_director).and_return(fake_results)  
      get :search_same_director_movies, {:search_terms => '1'}
      assigns(:movies).should == fake_results
    end

    it 'should select the same director search results template for rendering' do
      m=mock('Movie')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('George Lucas')
      Movie.stub(:find_all_by_director)#.and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      response.should render_template('search_same_director_movies') 
    end

    it 'flash with empty string' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('')
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      flash[:notice].should match(/'(.*)' has no director info/) 
    end

    it 'flash with empty nil' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return(nil)
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      flash[:notice].should match(/'(.*)' has no director info/) 
    end

    it 'redirect to movies_path with empty string' do
      m=mock('Movie', :title => 'Star Wars')
      #fake_results = [mock('Movie'),mock('Movie')]
      Movie.stub(:find_by_id).and_return(m)
      m.stub(:director).and_return('')
      #Movie.stub(:find_all_by_director).and_return(fake_results) 
      get :search_same_director_movies, {:search_terms => '1'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end

#############################################################################


    it 'should call the model method that performs TMDb search' do
      Movie.should_receive(:find_in_tmdb).with('hardware')
      post :search_tmdb, {:search_terms => 'hardware'}
    end

    it 'should select the Search Results template for rendering' do
      Movie.stub(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'hardware'}
      response.should render_template('search_tmdb')
    end

    it 'should make the TMDb search results available to that template' do
      fake_results = [mock('Movie'), mock('Movie')]
      Movie.stub(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'hardware'}
      # look for controller method to assign @movies
      assigns(:movie).should == fake_results
    end

#############################################################################

    it 'should appear a flash message if the movie does not exist' do
      Movie.stub(:find_in_tmdb).and_return([])
      post :search_tmdb, {:search_terms => 'Movie That Does Not Exist'}
      flash[:notice].should match(/'(.*)' was not found in TMDb./)
    end

    it 'should redirect to the index if the movie does not exist' do
      Movie.stub(:find_in_tmdb).and_return([])
      post :search_tmdb, {:search_terms => 'Movie That Does Not Exist'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end

#############################################################################

    it 'should appear a flash message when raise an api key exception' do
      Movie.stub(:find_in_tmdb).and_raise(Movie::InvalidKeyError)
      post :search_tmdb, {:search_terms => 'Fight Club'}
      flash[:notice].should match(/^Search not available$/)
    end

    it 'should redirect to the index when raise an api key exception' do
      Movie.stub(:find_in_tmdb).and_raise(Movie::InvalidKeyError)
      post :search_tmdb, {:search_terms => 'Fight Club'}
      response.should redirect_to(:controller => 'movies', :action => 'index')
    end

  end
end


