require 'fileutils'
require 'yaml'

require 'camera-control/logger'
require 'camera-control/utils'

module CameraControl
  class Mapping
    DEFAULT_FILENAME = File.expand_path '~/.config/camera-control/mapping'

    def initialize filename=DEFAULT_FILENAME
      @filename = filename

      @map = nil
      @available_slots = nil

      load_map
      initialize_available_slots
    end

    # Returns: [camera_id, camera_slot]
    def [] y, x
      key = "#{y},#{x}"
      @map[key]
    end

    # Allocates a slot, updates the mapping and returns the slot.
    def set y, x, cam_id
      key = "#{y},#{x}"

      if @map[key]
        old_id, old_slot = @map[key]
        free_slot old_id, old_slot
      end

      cam_slot = alloc_slot cam_id
      @map[key] = [cam_id, cam_slot]

      save_map

      cam_slot
    end

    private

    def load_map
      begin
        @map = YAML.load_file @filename
      rescue Errno::ENOENT
        @map = {}
        Logger.instance.info "Failed to load #{@filename}. " +
          "Not an error if this is the first time the application is running"
        save_map
      end
    end

    def save_map
      FileUtils.mkdir_p File.dirname(@filename)

      Tempfile.open_auto_rename @filename do |io|
        io.write YAML.dump(@map)
      end
    end

    # Slot 0x00 is reserved for the ‘rest’ position.
    def all_slots_available
      (0x01 .. 0xff).to_a
    end

    def initialize_available_slots
      @available_slots = {}

      @map.each_value do |cam_id, cam_slot|
        @available_slots[cam_id] ||= all_slots_available

        unless @available_slots[cam_id].delete cam_slot
          raise RuntimeError,
            "Corrupted map: #{cam_id}/#{cam_slot} allocated twice"
        end
      end
    end

    def alloc_slot cam_id
      @available_slots[cam_id] ||= all_slots_available

      cam_slot = @available_slots[cam_id].shift
      unless cam_slot
        raise RuntimeError, "All slots allocated: #{cam_id}"
      end
      cam_slot
    end

    # Note: this doesn’t remove the entry from @map.
    def free_slot cam_id, cam_slot
      @available_slots[cam_id] ||= all_slots_available

      if @available_slots[cam_id].include? cam_slot
        raise ArgumentError,
          "Tried to free a slot that is already free: #{cam_id}/#{cam_slot}",
          caller
      end

      @available_slots[cam_id] << cam_slot
    end
  end
end
