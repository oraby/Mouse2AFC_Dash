function sendPlotData (mapped_file, iTrial, bpod_data_custom, task_parameters_gui, trial_start_timestamp)
% The mapped file structure is as follows:
% byte 1 -> 4: iTrial number encoded as uint32
% byte 5 -> 8: Size of Bpod.Data.Custom struct encoded as uint32, call it x
% byte 9 -> 9 + x: the serialzed data of Bpod.Data.Custom
% let 9 + x + 1 = i
% byte i: i + 3: Size of TaskParameters.GUI, call it y
% byte i + 4: i + 4 + y: Serialized data of TaskParameters.GUI
% let i + y + 1 = j
% byte j -> j + 3: serialized TrialStartTimestamp array size, call it z
% byte j + 4 -> j + 4 + z: serialized TrialStartTimestamp array

    next_data_start = serializeAndWrite(mapped_file, 5, bpod_data_custom);
    next_data_start = serializeAndWrite(mapped_file, next_data_start,...
                                        task_parameters_gui);
    serializeAndWrite(mapped_file, next_data_start, trial_start_timestamp);
    % Write iTrial last so that only the listener would start reading the
    % data after we've processed it
    mapped_file.Data(1:4) = typecast(uint32(iTrial), 'uint8');
end

function next_data_start = serializeAndWrite(mapped_file, data_start, data)
    serialized_data = hlp_serialize(data);
    data_size = size(serialized_data);
    data_size = data_size(1);
    % disp("Serialized data size: " + string(data_size).join(" "));
    serialized_data_size = typecast(uint32(data_size), 'uint8');
    data_end = data_start + 4 -1;
    mapped_file.Data(data_start:data_end) = serialized_data_size;
    data_start = data_end + 1; data_end = data_start + data_size - 1;
    mapped_file.Data(data_start:data_end) = serialized_data;
    next_data_start = data_end + 1;
end
