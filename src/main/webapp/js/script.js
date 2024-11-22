document.addEventListener('DOMContentLoaded', () => {
    const voteButtons = document.querySelectorAll('.vote-button');

    voteButtons.forEach(button => {
        button.addEventListener('click', (event) => {
            event.preventDefault();

            // Temukan post ID dari elemen terdekat
            const postCard = button.closest('[id^="post-"]');
            if (!postCard) return;

            const postId = postCard.id.split('-')[1];
            const voteType = button.classList.contains('upvote') ? 'upvote' : 'downvote';

            fetch('vote', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `post_id=${postId}&vote_type=${voteType}`
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const upvoteCount = postCard.querySelector('.upvote-count');
                        const downvoteCount = postCard.querySelector('.downvote-count');
                        const upvoteButton = postCard.querySelector('.upvote');
                        const downvoteButton = postCard.querySelector('.downvote');

                        // Update counts
                        upvoteCount.textContent = data.upvotes;
                        downvoteCount.textContent = data.downvotes;

                        // Update button styles
                        if (voteType === 'upvote') {
                            upvoteButton.classList.add('voted');
                            downvoteButton.classList.remove('voted');
                        } else if (voteType === 'downvote') {
                            downvoteButton.classList.add('voted');
                            upvoteButton.classList.remove('voted');
                        }
                    } else {
                        alert(data.message || 'Error processing vote.');
                    }
                })
                .catch(error => console.error('Error:', error));
        });
    });
});



// Theme Toggle Logic
document.addEventListener('DOMContentLoaded', () => {
    const themeToggle = document.getElementById('theme-toggle');

    if (localStorage.getItem('theme') === 'dark') {
        document.body.classList.add('dark-mode');
        themeToggle.checked = true;
    } else {
        document.body.classList.remove('dark-mode');
        themeToggle.checked = false;
    }

    themeToggle.addEventListener('change', function () {
        if (this.checked) {
            document.body.classList.add('dark-mode');
            localStorage.setItem('theme', 'dark');
        } else {
            document.body.classList.remove('dark-mode');
            localStorage.setItem('theme', 'light');
        }
    });
});
