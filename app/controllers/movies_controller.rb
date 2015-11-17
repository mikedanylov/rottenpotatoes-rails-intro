class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    print params

    # calculate everytime in case there is new rating is added
    @all_ratings = Movie.select(:rating).distinct.pluck(:rating)
    
    if !session.has_key?("session_started")
      session[:session_started] = true
      session[:selected_ratings] = Movie.select(:rating).distinct.pluck(:rating)
      session[:movies] = Movie.all
    end
    
    if params[:title_sort]
      session.delete(:release_date_hilite)
      session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:title)
      session[:title_hilite] = 'hilite'
    elsif params[:release_date_sort]
      session.delete(:title_hilite)
      session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:release_date)
      session[:release_date_hilite] = 'hilite'
    elsif params[:ratings]
      session[:selected_ratings] = params[:ratings].keys.to_a
      if session[:title_hilite]
        session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:title)
      elsif session[:release_date_hilite]
        session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:release_date)
      else
        session[:movies] = Movie.where(rating: session[:selected_ratings])
      end
    else
      if session[:selected_ratings]
        if session[:title_hilite]
          session[:release_date_hilite] = 'no-hilite'
          session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:title)
        elsif session[:release_date_hilite]
          session[:title_hilite] = 'no-hilite'
          session[:movies] = Movie.where(rating: session[:selected_ratings]).order(:release_date)
        else
          session[:title_hilite] = 'no-hilite'
          session[:release_date_hilite] = 'no-hilite'
          session[:movies] = Movie.where(rating: session[:selected_ratings])
        end
      else
        if session[:title_hilite]
          session[:release_date_hilite] = 'no-hilite'
          session[:movies] = Movie.order(:title)
        elsif session[:release_date_hilite]
          session[:title_hilite] = 'no-hilite'
          session[:movies] = Movie.order(:release_date)
        else
          session[:title_hilite] = 'no-hilite'
          session[:release_date_hilite] = 'no-hilite'
          session[:movies] = Movie.all
        end
      end
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
