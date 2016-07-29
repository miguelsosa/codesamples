### The following is a sample controller for a ruby on rails
### application I built for a client.  I decided to provide this as an
### example of taking a framework code and expanding it for a
### particular use or implementation with soem interesting conditions.

### Note that there are some @todo items in this code. I apparently
### found a problem with a newer version of rails. Some other todo
### items were just notes of conversations I needed to have with some
### of the project stakeholder before making some decisions, or
### functionality for a future version.  This project was only a
### prototype to explore some ideas in the software, so not all
### decisions made it to the final release before moving on to
### implementation of a java application.

### Note that I've changed my condign style a bit since I wrote
### this. Now I would move as much of the logic in this function to
### the model itself and keep the controller more streamlined.

class StudiesController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_filter :authenticate
  THREE_DAYS = 3.days
  @FIVE_YEARS_AGO = 5.years.ago

  # GET /studies/new
  def new
    logger.debug "START new"
    @title = "Create new study"
    @study = Study.new
  end

  # GET /studies/1
  def show
    logger.debug "START show"

    @study ||= Study.find(params[:id])
    @title = "Show Study #{@study.accession}"

    @images ||= @study.images
    @series ||= @images.inject({}) do |r, i|
      i.get_thumb_url
      s = i.img_series
      if r[s].nil?
        r[s] = [i]
      else
        r[s] << i
      end
      r
    end || {}

    #binding.pry

    @current_series = current_series(params)

    @current_image = current_image
    @current_image_url = @current_image.try(:get_image_url) || "Image-missing.png"

    @first_image_idx = 0;
    @current_images = current_images
    if @current_images.empty?
      # Should everything be nil here?
      @last_image_idx = 0;
      @prev_image_idx = nil;
      @next_image_idx = nil;
    else
      @last_image_idx = @series[@current_series].size-1;
      @prev_image_idx = (current_image_idx > 0)?                current_image_idx - 1 : nil
      @next_image_idx = (current_image_idx < @last_image_idx) ? current_image_idx + 1 : nil
    end
    @current_bpm = current_bpm
  end

  # GET /studies
  def set_index_params_with_title(title)
    logger.debug "set index params with title: #{title}"

    three_days_ago = THREE_DAYS.ago
    @title = title

    if params[:show_all] == 'true'
      @search = Study.search({})
    else

      criteria = 0
      if params[:search]
        params[:search].each { |k, v|
          criteria += 1 unless v.blank?
        }
      end

      if criteria > 0
        logger.debug "search criteria: #{criteria}"
        @search = Study.search(params[:search])
      else
        logger.debug "Search criteria is empty"
        # todo: How can I create an empty search object? For now forcing
        # a query that will never match
        @search = Study.search({:accession_is_blank => true})
      end
    end
    @studies = @search.joins(:patient).order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 20)
  end
    
  def index
    logger.debug "START index"
    set_index_params_with_title("List of Studies")
    #render 'index'
  end

  # GET /studies/1/edit
  def edit
    logger.debug "START edit"
    @title = "Edit Study"
    @study = Study.find(params[:id])
  end

  # POST /studies
  def create
    logger.debug "START create"
    expire_page :action => "index"

    @study = Study.new(params[:study])
    if @study.save
      # @todo: a double render error *suddenly* appeared here. When
      # did it start? The 'and return' is the suggested fix, but this
      # does nothing.  Could it be a bug introduced in a later rails
      # version? Or maybe a change in teh expected behavior to make it
      # more strict. I don't know!!!!

      redirect_to(@study, :notice => 'Study was successfully created.') and return
    else
      logger.debug "Failed to save study"
      render :action => "new" and return
    end
    logger.debug "######################################################################################## END create?"
  end

  # PUT /studies/1
  def update
    @study = Study.find(params[:id])

    if @study.update_attributes(params[:study])
      redirect_to(@study, :notice => 'Study was successfully updated.') and return
    else
      render :action => "edit" and return
    end
  end

  # DELETE /studies/1
  def destroy
    @title = "Delete Study"

    @study = Study.find(params[:id])
    @study.destroy

    redirect_to(studies_url)
  end

  # GET /studies (with search criteria)
  def search
    set_index_params_with_title("Search results")
    flash.now[:notice] = "Search results #{params}"
    render 'index' and return
  end

  def current_studies
    @studies ||= session[:studies] || Study.find(:all)
  end

  def current_image_idx
    if params[:image_idx]
      params[:image_idx].to_i
    else
      0
    end
  end

  def current_image
    if @series.nil? || @series[@current_series].nil? || current_image_idx.nil?
      nil
    else
      @series[@current_series][current_image_idx]
    end
  end

  def current_images
    if @series && @series[@current_series] 
      @current_images = @series[@current_series] 
    else 
      @current_images = []
    end
  end

  def current_series(params = {})
    if params[:series]
      @current_series = params[:series].to_i
    else
      @current_series ||= params[:selected_image]? Studyimage.find(params[:selected_image]).series : (@series.keys[0] || 0)
    end
  end

  def current_bpm
    if @current_image
      # @todo: Change img_order to bpm if we decide to change the
      # meaning of the order field. Consider if we need to rename all
      # the images if this is the case.

      @current_image.img_order || "N/A"
    else
      "N/A"
    end
  end

  private
  
  def sort_column
    # TODO: Handle patient (full name), MRN, Physician (performing)
    if Study.column_names.include?(params[:sort]) || Patient.column_names.include?(params[:sort])
      params[:sort]
    else
      "accession"
    end
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
