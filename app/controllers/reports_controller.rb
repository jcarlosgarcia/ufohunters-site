class ReportsController < ApplicationController
  # GET /reports
  # GET /reports.json
  def index
    #@reports = Report.all.desc(:sighted_at).limit(10)

    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.json { render json: @reports }
    #end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    @report = Report.new

    @menu = "report"
    @page_title = "Report a UFO"
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end
    
  end

  # GET /reports/1/edit
  def edit
    #@report = Report.find(params[:id])
  end

  # POST /reports
  # POST /reports.json
  def create
    @numUFO = Report.count()

    @tmp = params[:report]
    @tmp["links"] = @tmp["links"].values

    @report = Report.new(@tmp)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Ufo model was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update
    #@report = Report.find(params[:id])

    #respond_to do |format|
     # if @report.update_attributes(params[:report])
       # format.html { redirect_to @report, notice: 'Ufo model was successfully updated.' }
       # format.json { head :no_content }
      #else
      #  format.html { render action: "edit" }
      #  format.json { render json: @report.errors, status: :unprocessable_entity }
      #end
    #end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
   # @report = Report.find(params[:id])
    #@report.destroy

    #respond_to do |format|
    #  format.html { redirect_to reports_url }
    #  format.json { head :no_content }
    #end
  end
end
