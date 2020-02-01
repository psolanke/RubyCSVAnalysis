require "csv"
require "set"
require "colorize" 

class CSVAnalysis
    @@ACCEPTED_FORMATS = [".csv"]
    @@RESULTS_FOLDER = "results"
    @@FILE_FORMAT_ERROR_STRING = "Invalid File Format!: %s\n"\
                                 "File is not of CSV format".colorize(:red)
    @@NO_FILE_ERROR_STRING = "Invalid Filename!: %s\n"\
                             "File does not exist".colorize(:red)

    def initialize(file_names)
        if file_names.size == 0
            STDERR.puts("ABORTED! No files were provided".colorize(:red))
            exit(true)
        end
        @file_names = file_names
        @data = get_consolidated_data()
    end
    
    def generate_report()
        ip_addr_analysis_results = get_aggregated_data(@data, :ip_addr, :http_request)
        response_code_analysis_results = get_aggregated_data(@data, :response_code)
        write_data_to_CSV("ip_address_results", ip_addr_analysis_results)
        write_data_to_CSV("response_code_results", response_code_analysis_results)
    end

    def write_data_to_CSV(file_name, data_hash_array)
        headers_set = Set.new
        data_hash_array.each{ |row|
            headers_set = headers_set | row.keys.to_set
        }
        headers_set = headers_set.to_a

        Dir.mkdir(@@RESULTS_FOLDER) unless File.exists?(@@RESULTS_FOLDER)

        file_full_path = File.join(@@RESULTS_FOLDER, file_name+"_"+Time.now.nsec.to_s+".csv")
        CSV.open(file_full_path, "wb", :headers => headers_set, :write_headers => true){ |csv|
            data_hash_array.each{ |row| csv << row }
        }
    end

    def get_aggregated_data(data, header1_name, header2_name = nil)
        analysis_results = []
        header1_unique_elements = get_column_unique_elements(data, header1_name)
        header1_unique_elements.each{ |header1_element|
            analysis_result_row = {header1_name => header1_element}
            rows = get_rows(data, header1_name, header1_element)
            analysis_result_row[:total_hits] = rows.size
            unless header2_name.nil?
                get_column_unique_elements(rows, header2_name).each{ |header2_element|
                    temp = get_rows(rows, header2_name, header2_element)
                    analysis_result_row[header2_element.to_sym] = temp.size
                }
            end
            analysis_results << analysis_result_row
        }
        return analysis_results
    end

    def get_column_unique_elements(data, header_name)
        return data[header_name.to_s].to_set
    end

    def get_rows(data, header_name, value)
        filtered_rows = data.select{ |row| row[header_name.to_s] == value}
        result_table = CSV.parse(filtered_rows[0].headers.to_csv, headers: true)
        filtered_rows.each{ |row| result_table << row }
        return result_table
    end
    
    def get_consolidated_data()
        data = nil
        @file_names.each{ |file_name|
            unless(@@ACCEPTED_FORMATS.include? File.extname(file_name))
                puts @@FILE_FORMAT_ERROR_STRING % [file_name]
                next
            end
            unless(File.exist?(file_name))
                puts @@NO_FILE_ERROR_STRING % [file_name]
                next
            end
            temp_data = parse_csv(file_name)
            if(data.nil?)
                data = temp_data
            else
                temp_data.each{ |row| data << row }
            end
        }
        return data
    end
    
    def parse_csv(file_name)
        return CSV.parse(File.read(file_name), headers: true)
    end
end

analyser = CSVAnalysis.new(ARGV)
analyser.generate_report()