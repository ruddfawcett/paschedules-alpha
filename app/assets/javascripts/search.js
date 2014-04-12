//Javascript not coffee...

var students = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('student'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: "/students.json"
});

var teachers = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('teacher'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: "/teachers.json"
});

var ready;
ready = function() {
    // initialize the bloodhound suggestion engine
    students.initialize();
    teachers.initialize();
    // promise
    //  .done(function() { console.log('Bloodhound initialized!'); })
    //  .fail(function() { console.log('Error during Bloodhound initialization!'); });

    // instantiate the typeahead UI
    $('#search').typeahead({
	hint: true,
	highlight: true,
	minLength: 1
    },
    {
        name: 'students',
        displayKey: 'student',
        source: students.ttAdapter(),
        templates: {
           header: '<h3 class="person-cat">Students</h3>'
        }
    },
    {
        name: 'teachers',
        displayKey: 'teacher',
        source: teachers.ttAdapter(),
	templates: {
           header: '<h3 class="person-cat">Teachers</h3>'
        }
    });
};

$(document).ready(ready);
$(document).on('page:load', ready);
