class SimulationController < ApplicationController
  def index
  end

  def exec
    @error = nil
    if params[:portal_data]
      begin
        portals = CfSim::DataFileParser.new(params[:portal_data].tempfile.path).parse
        portal_map = CfSim::PortalMap.new(portals)
        generator = CfSim::IntelMapUrlGenerator.new(portal_map)
        finder = CfSim::ControlFieldSetFinder.new(CfSim::PointList.new(portal_map.points).creatable_fields, limit_field_count: 10)
        fields_list = finder.find_max_count_fields_list
        max_area = fields_list.first.total_area
        @field_count = fields_list.first.size
        @results = fields_list.map { |fields| Result.new(generator.fields_link(fields), (fields.total_area * 100 / max_area).round(3)) }
      rescue => e
        handle_error(e)
        @error = 'File is invalid. Require CSV(latitude,longitude)'
        render status: :bad_request
      end
    end
  end

  private

  def handle_error(e)
    Rails.logger.error("#{e.class}: #{e.message}")
    e.backtrace.each { |b| Rails.logger.error("  #{b}") }
  end
end
