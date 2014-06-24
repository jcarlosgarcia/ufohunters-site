class ReportsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  include SimpleCaptcha::ControllerHelpers

  caches_action :index, :expires_in => 24.hour
  caches_page :show, :expires_in => 24.hour
  # GET /reports
  # GET /reports.json

  def index
    @reports = Report.where(:status => 1).without(:email,:description,:links,:status).desc(:sighted_at).limit(100)

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @report = Report.without(:email).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
    end
  end

  # GET /reports/nearof/1234/5678
  # GET /reports/nearof/1234/5678.json
  def nearof
      @coordenadas = [params[:longitud].to_i,params[:latitud].to_i]
      #@coordenadas = [-84.799473,35.250002]
      distance = 100 #km

      if @coordenadas
         @nearest = Report.where(:coord => { "$nearSphere" => @coordenadas , "$maxDistance" => (distance.fdiv(6371)) }).and(:status => 1).without(:email,:description,:links,:source,:status,:reported_at,:shape,:duration).limit(50)
      end

      respond_to do |format|
        format.html # nearof.html.erb
        format.json { render json: @nearest }
      end
  end


  # GET /reports/new
  # GET /reports/new.json
  def new

    @numUFO = Report.where(:status => 1).count()

    @report = Report.new

    @menu = "report"
    @page_title = "Report a UFO"
    @page_description = "Have you seen a UFO? Report your experience filling in the report form"
    @notice = 'Introduce the text of the image'
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @report }
    end

  end


  # POST /reports
  # POST /reports.json

  def create
    @numUFO = Report.count()

    @tmp = params[:report]
    @tmp["links"] = @tmp["links"].values
    unless @tmp["image_cloudinary"].blank?  
        @tmp["image_cloudinary"] = @tmp["image_cloudinary"].values
    end
    @tmp["status"] = 0
    @tmp["image"] = ""

    if @tmp["coord"].empty?
      @tmp["coord"] = [0,0]
    else
      @tmp["coord"] = @tmp["coord"].split(",").map { |s| s.to_f }
    end

    @tmp["source"] = "ufo-hunters.com"
    @tmp["sighted_at"] = Date.strptime(@tmp["sighted_at"], '%m/%d/%Y').strftime('%Y%m%d')
    @tmp["reported_at"] = Date.strptime(@tmp["reported_at"], '%m/%d/%Y').strftime('%Y%m%d')

    @report = Report.new(@tmp)

    if simple_captcha_valid?

        respond_to do |format|
          if @report.save
            format.html { redirect_to @report, notice: 'Ufo model was successfully created.' }
            format.json { render json: @report, status: :created, location: @report }
          else
            format.html { render action: "new" }
            format.json { render json: @report.errors, status: :unprocessable_entity }
          end
        end

    else
        @report["sighted_at"] = ""
        @report["reported_at"] = ""
        @report["links"] = ""
        respond_to do |format|
            @notice = 'You must enter the text of the image'
            format.html { render action: "new", notice: 'You must enter the text of the image'}
            format.json { render json: @report.errors, status: :unprocessable_entity, notice: 'You must enter the text of the image' }
        end

    end


  end


  def sightings
    @reports = Report.where(:status => 1, :source => "ufo-hunters.com", :coord =>  {"$exists" => 1}).without(:email,:links,:source,:status,:shape,:duration).desc(:sighted_at).limit(100)

     respond_to do |format|
       format.xml
     end
  end


  def country
     codeCountry = params[:id]
      listaPais = Countries.where({"cod" => codeCountry}).limit(1)

      listaPais.each do |country|
         @nameCountry = country.name
         @coordCountry = country.center
         @zoom = country.zoom
         @pais = country.geometry
      end

      type = ""
      coordinates = ""
      @pais.each_with_index do |datos, index|
         if index==0
            type = datos[1]
         else
            coordinates =  datos[1]
         end
      end

      if type == 'Polygon'
         @reports = Report.where(:coord => {"$geoWithin" => {"$polygon" => coordinates[0]}}).and(:status => 1).order_by(:sighted_at.desc).limit(100)
      else
         coordinates.each_with_index do |coordinatesdatos,index|
            if index == 0
               @reports = Report.where(:coord => {"$geoWithin" => {"$polygon" => coordinatesdatos[0]}}).and(:status => 1).order_by(:sighted_at.desc).limit(100)
            else
               @reports = @reports + Report.where(:coord => {"$geoWithin" => {"$polygon" => coordinatesdatos[0]}}).and(:status => 1).order_by(:sighted_at.desc).limit(100)
            end
         end
      end

      respond_to do |format|
         format.xml
      end

   end

end