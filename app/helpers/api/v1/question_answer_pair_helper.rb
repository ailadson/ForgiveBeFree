module Api::V1::QuestionAnswerPairHelper
    def self.content_filter(client, userId, answer)
        response = client.completions(
            engine: "content-filter-alpha",
            parameters: {
                prompt: "<|endoftext|>"+ answer + "\n--\nLabel:",
                max_tokens: 1,
                temperature: 0.0,
                top_p: 0,
                logprobs: 10,
                user: userId,
            }
        )

        output_label = response["choices"][0]["text"]
        # This is the probability at which we evaluate that a "2" is likely real
        # vs. should be discarded as a false positive
        toxic_threshold = -0.355

        if output_label == "2"
            # If the model returns "2", return its confidence in 2 or other output-labels
            logprobs = response["choices"][0]["logprobs"]["top_logprobs"][0]

            # If the model is not sufficiently confident in "2",
            # choose the most probable of "0" or "1"
            # Guaranteed to have a confidence for 2 since this was the selected token.
            if logprobs["2"] < toxic_threshold
                logprob_0 = logprobs["0"]
                logprob_1 = logprobs["1"]

                # If both "0" and "1" have probabilities, set the output label
                # to whichever is most probable
                if !logprob_0.nil? and !logprob_1.nil?
                    if logprob_0 >= logprob_1
                        output_label = "0"
                    else
                        output_label = "1"
                    end
                # If only one of them is found, set output label to that one
                elsif !logprob_0.nil?
                    output_label = "0"
                elsif !logprob_1.nil?
                    output_label = "1"
                end

                # If neither "0" or "1" are available, stick with "2"
                # by leaving output_label unchanged.
            end
        end

        # if the most probable token is none of "0", "1", or "2"
        # this should be set as unsafe
        if !["0", "1", "2"].include?(output_label)
            output_label = "2"
        end

        return output_label
    end

    def self.ask_question(wom_chunk, question, userId)
        client = ::OpenAI::Client.new(access_token:ENV['OPENAI_ACCESS_TOKEN'])
        prompt = wom_chunk + "\n\nQuestion: " + question + "\n\nAnswer: "
        answer = ''

        loop do
            response = client.completions(
                engine: "text-davinci-001",
                parameters: {
                    prompt: prompt,
                    max_tokens: 64,
                    temperature: 1.0,
                    frequency_penalty: rand(0.33..1.0),
                    presence_penalty: rand(0.33..1.0),
                    user: userId,
                }
            )

            if response['error']
                if response['error']['message'].start_with?('This model\'s maximum context length is 2049 tokens')
                    positions = wom_chunk.enum_for(:scan, /Question: /).map { Regexp.last_match.begin(0) }

                    if (positions.size > 1)
                        wom_chunk = wom_chunk[0...positions[0]] + wom_chunk[positions[1]..]
                    else
                        wom_words = wom_chunk.split(' ')
                        wom_chunk = wom_words[200, wom_words.size].join(' ')
                    end

                    prompt = wom_chunk + "\nQuestion: " + question + "\nAnswer: " + answer
                    next
                end

                if response['error']['message'].include?('quota')
                    return { filter: "0", answer: 'Quota limit hit. Contact Ira so he can add more quota' }
                end

                if response['error']['message'].start_with?('You didn\'t provide an API key')
                    return { filter: "0", answer: 'No API Key' }
                end
            end

            answer += response['choices'][0]['text']
            prompt += response['choices'][0]['text']
            break if response['choices'][0]['finish_reason'] == 'stop'
        end

        answer
        filter = self.content_filter(client, userId, answer)

        return { answer: answer, filter: filter }
    end
end