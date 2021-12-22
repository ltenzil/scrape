class KeywordsController < ApplicationController
  before_action :set_keyword, only: %i[ show edit update destroy ]

  # GET /keywords or /keywords.json
  def index
    @keywords = Keyword.order(hits: :desc)
  end

  # GET /keywords/1 or /keywords/1.json
  def show
  end

  # GET /keywords/new
  def new
    @keyword = current_user.keywords.new
  end

  # GET /keywords/1/edit
  def edit
  end

  # POST /keywords or /keywords.json
  def create
    @keyword = current_user.keywords.create(keyword_params)

    respond_to do |format|
      if @keyword.errors.blank?
        @keyword.search_google
        format.html { redirect_to keyword_url(@keyword.id), notice: "Keyword was successfully created." }
        format.json { render :show, status: :created, location: @keyword }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keywords/1 or /keywords/1.json
  def update
    respond_to do |format|
      if @keyword.update(keyword_params)
        @keyword.search_google
        format.html { redirect_to keyword_url(@keyword), notice: "Keyword was successfully updated." }
        format.json { render :show, status: :ok, location: @keyword }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1 or /keywords/1.json
  def destroy
    @keyword.destroy

    respond_to do |format|
      format.html { redirect_to keywords_url, notice: "Keyword was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def new_upload
  end

  def bulk_upload
    begin
      contents      = params[:file].read
      keyword_list = contents.split(',').uniq.map(&:squish)
      @results = { total: keyword_list.uniq.size }
      if @results[:total] <= Keyword::LIMIT
        keywords, failures = Keyword.bulk_search(keyword_list, current_user.id)
        @results[:keywords] = keywords
        @results[:failures] = failures
      else
        @results[:count_error] =
          "Search limit is #{Keyword::LIMIT}, Please reduce the keywords and try again"        
      end
      debugger
    rescue StandardError => e
      flash[:notice] = "Please upload csv file. <br/> Following error raised: #{e.message}"
    end
    render "bulk_upload_list"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyword
      @keyword = current_user.find_keyword(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def keyword_params
      params.require(:keyword).permit(:value, :hits, :stats)
    end
end
