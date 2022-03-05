module Api::V1::QuestionAnswerPairHelper
    def self.ask_question(wom_chunk, question)
        client = ::OpenAI::Client.new(access_token:ENV['OPENAI_ACCESS_TOKEN'])
        prompt = wom_chunk + "\nQuestion: " + question + "\nAnswer: "
        answer = ''

        loop do
            response = client.completions(engine: "text-davinci-001", parameters: { prompt: prompt, max_tokens: 64 })

            if response['error']
                if response['error']['message'].start_with?('This model\'s maximum context length is 2049 tokens')
                    wom_words = wom_chunk.split(' ')
                    wom_chunk = wom_words[200, wom_words.size].join(' ')
                    prompt = wom_chunk + "\nQuestion: " + question + "\nAnswer: " + answer
                    next
                end

                if response['error']['message'].include?('quota')
                    return 'Quota limit hit. Contact Ira so he can add more quota'
                end

                if response['error']['message'].start_with?('You didn\'t provide an API key')
                    return 'No API Key'
                end
            end

            answer += response['choices'][0]['text']
            prompt += response['choices'][0]['text']
            break if response['choices'][0]['finish_reason'] == 'stop'
        end

        answer
    end
end