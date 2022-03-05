import React, { useState, useEffect, useRef } from "react";
import { QuestionCircleOutlined, ExclamationCircleOutlined } from '@ant-design/icons';
import { Tooltip, Modal } from 'antd';
import { getChunk } from '../util';

const Home = () => {
  const [chunk, setChunk] = useState(null);
  const [qas, setQAs] = useState([]);
  const [question, setQuestion] = useState('');
  const [loading, setLoading] = useState(false);
  const [noteModalVisible, setNoteModalVisible] = useState(false);
  const [aboutModalVisible, setAboutModalVisible] = useState(false);

  const qaRef = useRef(null)

  useEffect(() => {
    if (chunk === null) {
      const c = getChunk();
      setChunk(c);
    }
  }, []);

  const askQuestion = () => {
    const url = '/api/v1/ask_question';
    const data = new FormData();
    data.set('question', question);
    data.set('chunk', chunk);
    const options = {
      method: 'POST',
      body: data,
      headers: {
        'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").getAttribute("content"),
      },
    }
    fetch(url, options)
      .then(response => {
        if (response.ok) {
          return response.json();
        }
        throw new Error("Network response was not ok.");
      })
      .then((response) => {
        setQAs(qas.concat(response));
        setLoading(false);
        setQuestion('');
        const chunkAddition = `\nQuestion: ${response.question.trim()}\nAnswer: ${response.answer.trim()}`
        setChunk(chunk + chunkAddition);
        qaRef.current.scrollIntoView({ behavior: 'smooth' });
      })
      .catch(() => console.log('error'));
  };

  const renderSidbar = () => (
    <div className="sidebar">
       <Tooltip title="About">
        <QuestionCircleOutlined
          style={{ fontSize: '50px', cursor: 'pointer' }}
          onClick={() => setAboutModalVisible(true)}
        />
      </Tooltip>
      <br />
      <br />
      <br />
      <Tooltip title="Important Note!">
        <ExclamationCircleOutlined
          style={{ fontSize: '50px', cursor: 'pointer' }}
          onClick={() => setNoteModalVisible(true)}
        />
      </Tooltip>
      <br />
      <br />
      <br />
      <form action="https://www.paypal.com/donate" method="post" target="_top">
      <input type="hidden" name="business" value="9VY4SBPBMP6XN" />
      <input type="hidden" name="no_recurring" value="0" />
      <input type="hidden" name="item_name" value="10 cents a question covers the cost of running the AI.
      More is appreciated, but not expected." />
      <input type="hidden" name="currency_code" value="USD" />
      <input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" border="0" name="submit" title="PayPal - The safer, easier way to pay online!" alt="Donate with PayPal button" />
      <img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1" />
      </form>
    </div>
  );

  let containerClassName = 'question-input-container';
  if (loading) {
    containerClassName += ' loading';
  }
  if (qas.length) {
    containerClassName += ' active';
  }

  return (
    <>
    { renderSidbar() }
    {
      qas.length && (
        <div className="qas-container">
            {
              qas.map((qa) => (
                <div key={qa.id} className="qa-container">
                  <div>
                    <span style={{ fontWeight: 600 }}>Question: </span>{qa.question.trim()}
                  </div>
                  <div>
                  <span style={{ fontWeight: 600 }}>Answer: </span>{qa.answer.trim()}
                  </div>
                </div>
              ))
            }
            <div ref={qaRef}/>
          </div>
      )
    }
      <div className={containerClassName}>
        <input
          className="question-input"
          value={question}
          onChange={(e) => setQuestion(e.currentTarget.value)}
          onKeyPress={(e) => {
            if (e.key === 'Enter') {
              setLoading(true);
              askQuestion();
            }
          }}
        />
      </div>
      <Modal
        title="About"
        visible={aboutModalVisible}
        footer={null}
        onCancel={() => {
          setAboutModalVisible(false)
        }}
      >
        <p>Some contents...</p>
        <p>Some contents...</p>
        <p>Some contents...</p>
      </Modal>
      <Modal
        title="Important Note"
        visible={noteModalVisible}
        footer={null}
        onCancel={() => {
          setNoteModalVisible(false)
        }}
      >
        <p>Some contents...</p>
        <p>Some contents...</p>
        <p>Some contents...</p>
      </Modal>
    </>
  )
};

export default Home;
