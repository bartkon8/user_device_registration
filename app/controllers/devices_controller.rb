# frozen_string_literal: true

class DevicesController < ApplicationController
  rescue_from RegistrationError::Unauthorized, with: :render_unauthorized
  rescue_from AssigningError::DeviceNotFound,  with: :render_not_found
  rescue_from AssigningError::Base,            with: :render_unprocessable

  before_action :authenticate_user!, only: %i[assign unassign]
  def assign
    AssignDeviceToUser.new(
      requesting_user: current_user,
      serial_number: params[:serial_number],
      new_device_owner_id: params[:new_device_owner_id].to_i
    ).call
    head :ok
  end

  def unassign
    ReturnDeviceFromUser.new(
      user: current_user,
      serial_number: params[:serial_number],
      from_user: params[:from_user]
    ).call
    head :ok
  end

  private

  def device_params
    params.permit(:new_owner_id, :serial_number)
  end

  def render_unprocessable(e)
    render json: { error: e.class.name.split('::').last }, status: :unprocessable_entity
  end

  def render_not_found(e)
    render json: { error: 'NotFound' }, status: :not_found
  end

  def render_unauthorized(e)
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

end
