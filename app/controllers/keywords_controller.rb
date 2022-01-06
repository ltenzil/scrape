class KeywordsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :set_keyword, only: %i[edit update destroy]

  # GET /keywords or /keywords.json
  def index
    @keywords = Keyword.search(params)
  end

  # GET /keywords or /keywords.json
  def user_keywords
    @keywords = Keyword.search(params.merge(user_id: current_user.id))
  end

  # GET /keywords/1 or /keywords/1.json
  def show
    @keyword = Keyword.find(params[:id])
  end

  # GET /keywords/new
  def new
    @keyword = Keyword.new
  end

  # GET /keywords/1/edit
  def edit; end

  # POST /keywords or /keywords.json
  def create
    @keyword = keyword_service.search_and_save(keyword_params[:value])
    respond_to do |format|
      if @keyword.persisted?
        format.html { redirect_to keyword_url(@keyword.id), notice: 'Keyword was successfully created.' }
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
        keyword_service.search_and_update(@keyword)
        format.html { redirect_to keyword_url(@keyword.id), notice: 'Keyword was successfully updated.' }
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
      format.html { redirect_to keywords_url, notice: 'Keyword was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_upload; end

  def bulk_upload
    begin
      queries  = CsvService.new(file: params[:file]).read_file
      @results = { total: queries.size, keywords: [], failures: [] }
      if @results[:total] <= Keyword::LIMIT
        keywords, failures = keyword_service.bulk_search_and_save(queries)
        @results[:keywords] = keywords
        @results[:failures] = failures
      else
        @results[:count_error] =
          "Search limit is #{Keyword::LIMIT}, Please reduce the keywords and try again"
      end
    rescue StandardError => e
      @results = { total: 0, keywords: [], failures: [] } if @results.nil?
      flash[:notice] = "Please upload csv file. <br/> Following error raised: #{e.message}"
    end
    render 'bulk_upload_list'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_keyword
    @keyword = current_user.keywords.find_by(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def keyword_params
    params.require(:keyword).permit(:value, :hits, :stats)
  end

  def keyword_service
    KeywordService.new(user: current_user)
  end

end
