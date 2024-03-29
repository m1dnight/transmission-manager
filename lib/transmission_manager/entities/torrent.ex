defmodule TransmissionManager.Torrent do
  @moduledoc """
  Model of a transmission torrent.
  """
  alias __MODULE__
  alias TransmissionManager.Tracker
  # type of the json dictionary coming from the Transmission api
  @type torrent_map :: %{
          :addedDate => integer(),
          :downloadedEver => integer(),
          :id => integer(),
          :isFinished => boolean(),
          :name => String.t(),
          :percentDone => float(),
          :rateDownload => integer(),
          :rateUpload => integer(),
          :sizeWhenDone => integer(),
          :uploadRatio => float(),
          :uploadedEver => any(),
          :activityDate => integer(),
          :trackers => [
            %{
              :id => integer(),
              :announce => String.t(),
              :scrape => String.t(),
              :tier => integer(),
              :sitename => String.t()
            }
          ],
          optional(any()) => any()
        }

  @type t :: %__MODULE__{
          :added_date => DateTime.t(),
          :activity_date => DateTime.t(),
          :downloaded => integer(),
          :id => integer(),
          :is_finished => boolean(),
          :name => String.t(),
          :percent_done => float(),
          :rate_download => integer(),
          :rate_upload => integer(),
          :size_when_done => integer(),
          :upload_ratio => float(),
          :uploaded => integer(),
          :status =>
            :stopped
            | :queued_to_verify
            | :verifying
            | :queued_to_download
            | :downloading
            | :queued_to_seed
            | :seeding,
          :trackers => [Tracker.t()]
        }
  @keys [
    :name,
    :id,
    :added_date,
    :activity_date,
    :is_finished,
    :rate_download,
    :rate_upload,
    :size_when_done,
    :upload_ratio,
    :percent_done,
    :uploaded,
    :downloaded,
    :status,
    :trackers
  ]
  @enforce_keys @keys
  defstruct @keys

  @spec new(torrent_map()) :: t()
  def new(torrent_map) do
    # https://github.com/transmission/transmission/blob/main/docs/rpc-spec.md

    %Torrent{
      id: torrent_map.id,
      name: torrent_map.name,
      added_date: DateTime.from_unix!(torrent_map.addedDate),
      is_finished: torrent_map.isFinished,
      rate_download: torrent_map.rateDownload,
      rate_upload: torrent_map.rateUpload,
      size_when_done: torrent_map.sizeWhenDone,
      upload_ratio: torrent_map.uploadRatio * 1.0,
      percent_done: torrent_map.percentDone * 100,
      uploaded: torrent_map.uploadedEver,
      downloaded: torrent_map.downloadedEver,
      status: parse_status(torrent_map),
      activity_date: DateTime.from_unix!(torrent_map.activityDate),
      trackers: parse_trackers(torrent_map)
    }
  end

  defp parse_status(torrent_map) do
    case torrent_map.status do
      0 -> :stopped
      1 -> :queued_to_verify
      2 -> :verifying
      3 -> :queued_to_download
      4 -> :downloading
      5 -> :queued_to_seed
      6 -> :seeding
    end
  end

  defp parse_trackers(torrent_map) do
    torrent_map.trackers
    |> Enum.map(fn tracker ->
      %Tracker{
        id: tracker.id,
        announce: tracker.announce,
        scrape: tracker.scrape,
        tier: tracker.tier,
        sitename: tracker.sitename
      }
    end)
  end
end

defimpl String.Chars, for: TransmissionManager.Torrent do
  def to_string(torrent) do
    torrent.name
  end
end
