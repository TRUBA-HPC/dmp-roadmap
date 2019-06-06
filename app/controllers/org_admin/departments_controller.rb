# frozen_string_literal: true

class OrgAdmin::DepartmentsController < ApplicationController

  after_action :verify_authorized
  respond_to :html

  # GET add new department
  def new
    @department = Department.new
    authorize @department
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)
    authorize @department
    @department.org_id = current_user.org_id

    if @department.save
      flash.now[:notice] = success_message(@department, _("created"))
      # reset value
      @department = nil
      render :new
    else
      flash.now[:alert] = failure_message(@department, _("create"))
      render :new
    end
  end

  # GET /departments/1/edit
  def edit
    @department = Department.find(params[:id])
    authorize @department
  end

  # PUT /departments/1
  def update
    @department = Department.find(params[:id])
    authorize @department
    @department.org_id = current_user.org_id

    if @department.update(department_params)
      flash.now[:notice] = success_message(@department, _("saved"))
      render :edit
    else
      flash.now[:alert] = failure_message(@department, _("save"))
      render :edit
    end
  end

  # DELETE /departments/1
  def destroy
    @department = Department.find(params[:id])
    authorize @department
    url = "#{admin_edit_org_path(current_user.org_id)}\#departments"
    if @department.destroy
      flash[:notice] = success_message(@department, _("deleted"))
      redirect_to url
    else
      flash[:alert] = failure_message(@department, _("delete"))
      redirect_to url
    end
  end


  private

  def department_params
    params.require(:department).permit(:id, :name, :code, :org_id)
  end

end